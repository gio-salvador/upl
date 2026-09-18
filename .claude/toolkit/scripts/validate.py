#!/usr/bin/env python3
"""Validate a declaration against its schema (Goals G35, G48, G41).

Implements the subset of JSON Schema these contracts actually use: type, required, enum, const,
pattern, properties, additionalProperties, items, default. A dependency on a full validator was
considered and rejected: the schemas are deliberately simple, and `jsonschema` is not installed
on every machine this must run on, so requiring it would trade a real portability property for
convenience (G44).

The failure mode matters more than the check. A missing REQUIRED field with no safe default is a
halt, naming the field and the file (TK-011). A missing optional field with a default is
reported and filled from the default, never invented.

Usage:
  validate.py --schema schemas/repo-profile.schema.json --file .claude/profile.yaml
  validate.py --instance                  # the instance contract (Goal G24)
Exit: 0 valid, 1 invalid, 2 usage or environment error.
"""
import argparse, json, os, re, subprocess, sys

def load(path):
    with open(path, "r", encoding="utf-8") as fh:
        text = fh.read()
    # Decide by CONTENT, not by extension. The lockfile is YAML named `.lock`, so an
    # extension-driven reader treated it as JSON and failed: it could never be validated, which
    # was a hole in "nothing is read unvalidated" (TK-069). JSON is a subset of YAML, so trying
    # JSON first and falling back keeps both fast and correct.
    try:
        return json.loads(text)
    except ValueError:
        pass
    try:
        import yaml
    except ImportError:
        die("%s is not JSON, and pyyaml is not installed to read it as YAML" % path)
    return yaml.safe_load(text)

def die(msg, code=2):
    print("validate: %s" % msg, file=sys.stderr)
    sys.exit(code)

def root():
    try:
        return subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True,
                              text=True, check=True).stdout.strip()
    except subprocess.CalledProcessError:
        die("not inside a git repository")

# "null" belongs here: manifests use an explicit null to mean "declared, and deliberately
# unset", which is different from an absent key. Without it, a schema saying ["string","null"]
# rejected every manifest that used the null arm.
TYPES = {"object": dict, "array": list, "string": str, "integer": int, "boolean": bool,
         "number": (int, float), "null": type(None)}

def check(node, schema, path, errs, warns):
    if schema is None:
        return
    if "const" in schema and node != schema["const"]:
        errs.append("%s: must be %r, got %r" % (path, schema["const"], node)); return
    if "enum" in schema and node not in schema["enum"]:
        errs.append("%s: must be one of %s, got %r" % (path, schema["enum"], node)); return
    # `type` may be a single name or a list of alternatives. Real manifests use the list form
    # (a field that is legitimately either a string or a list), and treating the list as a dict
    # key crashed the validator on four of the fleet's manifests.
    t = schema.get("type")
    types = [t] if isinstance(t, str) else (t or [])
    known = [x for x in types if x in TYPES]
    if known and not any(isinstance(node, TYPES[x]) for x in known):
        # bool is an int in Python; keep the distinction, it hides real mistakes otherwise.
        if not ("integer" in known and isinstance(node, bool) is False and isinstance(node, int)):
            errs.append("%s: expected %s, got %s"
                        % (path, " or ".join(known), type(node).__name__)); return
    t = known[0] if known else None
    if "pattern" in schema and isinstance(node, str) and not re.search(schema["pattern"], node):
        errs.append("%s: %r does not match %s" % (path, node, schema["pattern"])); return
    if t == "object" or isinstance(node, dict):
        props = schema.get("properties", {})
        for req in schema.get("required", []):
            if req not in (node or {}):
                sub = props.get(req, {})
                if "default" in sub:
                    warns.append("%s.%s: missing, using default %r" % (path, req, sub["default"]))
                else:
                    errs.append("%s.%s: REQUIRED and has no safe default. Set it, or run "
                                "`sct init` to scaffold it." % (path, req))
        if schema.get("additionalProperties") is False:
            for k in (node or {}):
                if k not in props:
                    errs.append("%s.%s: not a known field (typo, or a schema bump this file "
                                "has not migrated to)" % (path, k))
        for k, v in (node or {}).items():
            if k in props:
                check(v, props[k], "%s.%s" % (path, k), errs, warns)
    if t == "array" and isinstance(node, list) and "items" in schema:
        for i, v in enumerate(node):
            check(v, schema["items"], "%s[%d]" % (path, i), errs, warns)

def validate_instance(r, home):
    """The instance contract: every entry has a template, is gitignored, and is not tracked."""
    errs, warns = [], []
    man = os.path.join(home, "instance-manifest.yaml")
    if not os.path.exists(man):
        return ["instance-manifest.yaml is missing"], []
    data = load(man) or {}
    tracked = set(subprocess.run(["git", "-C", home, "ls-files"], capture_output=True,
                                 text=True).stdout.split())
    seen_templates = set()
    for entry in data.get("instance", []):
        p, tpl = entry.get("path"), entry.get("template")
        if not p:
            errs.append("instance entry with no path"); continue
        if p in tracked:
            errs.append("%s: instance data is TRACKED" % p)
        rc = subprocess.run(["git", "-C", home, "check-ignore", "-q", p]).returncode
        if rc != 0:
            errs.append("%s: instance path is not gitignored" % p)
        if tpl:
            seen_templates.add(tpl)
            # TRACKED, not merely present. A template that exists on the authoring machine but
            # was never committed looks fine here and is missing for everyone else. Checking
            # the working tree would make this pass exactly where it must not.
            if tpl not in tracked:
                if os.path.exists(os.path.join(home, tpl)):
                    errs.append("%s: template %s exists but is NOT TRACKED "
                                "(likely swallowed by a .gitignore directory rule)" % (p, tpl))
                else:
                    errs.append("%s: declared template %s does not exist" % (p, tpl))
        elif entry.get("required"):
            errs.append("%s: required instance entry has no template" % p)
    for f in tracked:
        if f.endswith(".example") and f not in seen_templates:
            warns.append("%s: a template with no instance-manifest entry" % f)
    return errs, warns

def main():
    ap = argparse.ArgumentParser(add_help=True)
    ap.add_argument("--schema"); ap.add_argument("--file")
    ap.add_argument("--instance", action="store_true")
    ap.add_argument("--quiet", action="store_true")
    a = ap.parse_args()
    r = root()
    home = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    if a.instance:
        # Validate the manifest belonging to the repository being checked, falling back to the
        # toolkit's own. A vendored copy must be able to check its host, and a test must be able
        # to check a fixture, so the target cannot be hardwired to where this script lives.
        target = r if os.path.exists(os.path.join(r, "instance-manifest.yaml")) else home
        errs, warns = validate_instance(r, target)
    else:
        if not (a.schema and a.file):
            die("need --schema and --file, or --instance")
        if not os.path.exists(a.file):
            die("%s does not exist. Run `sct init` to create it." % a.file, 1)
        errs, warns = [], []
        check(load(a.file), load(a.schema), os.path.basename(a.file), errs, warns)
        doc = load(a.file) or {}
        for t in (doc.get("todo") or []):
            warns.append("unresolved from `sct init`: %s" % t)

    for w in warns:
        if not a.quiet:
            print("warn   %s" % w, file=sys.stderr)
    for e in errs:
        print("BLOCK  %s" % e, file=sys.stderr)
    if errs:
        print("validate: %d blocking finding(s)" % len(errs), file=sys.stderr)
        return 1
    return 0

if __name__ == "__main__":
    sys.exit(main())
