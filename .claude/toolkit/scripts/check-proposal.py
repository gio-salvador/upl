#!/usr/bin/env python3
"""Judge a repository's efficiency-proposal tracker. Called by check-proposal.sh, which owns
the documentation of what this decides and why (single ownership, G59)."""
import json, os, re, subprocess, sys, tempfile

try:
    import yaml
except ImportError:
    print("check-proposal: PyYAML unavailable; cannot read the tracker", file=sys.stderr)
    sys.exit(2)

path, quiet = sys.argv[1], sys.argv[2] == "1"

# Derived from this file's own location, never from an argument. `run-record.py` beside it
# already did this; taking the path from argv instead made the interpreter call downstream
# argv-derived, and a host's Semgrep flagged it as a blocking tainted-subprocess finding on the
# first refresh that vendored this file (TK-085).
home = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

with open(path, encoding="utf-8") as fh:
    data = yaml.safe_load(fh) or []
if not isinstance(data, list):
    print("check-proposal: %s is not a list of proposals" % path, file=sys.stderr)
    sys.exit(1)

# The three shapes G57 puts out of scope, as they appear in a change description. Each is a
# verb of removal or reduction bound to a thing whose whole purpose is to catch errors.
OUT_OF_SCOPE = [
    (re.compile(r"\b(remov|drop|skip|disabl|omit|cut|elid)\w*\b[^.]{0,60}?"
                r"\b(review(er)?s?|lens(es)?|panel|critic|audit(or)?s?)\b", re.I),
     "weakening a reviewer"),
    (re.compile(r"\b(remov|drop|skip|disabl|omit|forgo|cut)\w*\b[^.]{0,60}?"
                r"\b(citation|cit(e|ing)|ground(ing)?|source|verif\w+|fact.?check\w*|evidence)\b", re.I),
     "dropping a grounding step"),
    (re.compile(r"\b(collaps|lower|reduc|shorten|loosen|relax|weaken)\w*\b[^.]{0,60}?"
                r"\b(exit condition|loop|cap|round(s)?|threshold|gate|guardrail|PASS bar)\b", re.I),
     "collapsing a loop's exit condition"),
]

blocks = warns = 0
def block(m):
    global blocks; blocks += 1
    print("BLOCK  %s" % m, file=sys.stderr)
def note(m):
    print("       %s" % m, file=sys.stderr)
def warn(m):
    global warns; warns += 1
    print("warn   %s" % m, file=sys.stderr)

schema = os.path.join(home, "schemas", "efficiency-proposal.schema.json")
for i, prop in enumerate(data):
    label = (prop or {}).get("id") if isinstance(prop, dict) else None
    label = label or "proposal #%d" % (i + 1)

    # 1. Shape, judged by the same validator every other declaration goes through.
    #
    # The temporary file's name comes from `tempfile`, never from the tracker path. Deriving it
    # from an argument put an argv-derived string into the subprocess argument list, which is
    # what Semgrep's tainted-subprocess rule actually flagged in a host's security scan; moving
    # `home` off argv first fixed a different taint and left this one firing (TK-085). It also
    # stops the check writing a scratch file into the repository it is inspecting.
    fd, tmp = tempfile.mkstemp(prefix="sct-proposal-", suffix=".json")
    with os.fdopen(fd, "w", encoding="utf-8") as fh:
        json.dump(prop, fh)
    rc = subprocess.run([sys.executable, os.path.join(home, "scripts", "validate.py"),
                         "--schema", schema, "--file", tmp],
                        capture_output=True, text=True)
    os.unlink(tmp)
    if rc.returncode != 0:
        block("%s: does not validate against the proposal schema" % label)
        for line in (rc.stdout + rc.stderr).splitlines():
            if line.strip():
                note(line.strip())
        continue

    verdict = prop["quality"]["verdict"]
    rec = prop["recommendation"]

    # 2. The cross-field rule: only a quality-neutral or quality-positive proposal may be
    #    recommended for adoption. Recording a rejected idea stays allowed.
    if verdict == "not-safe" and rec in ("adopt", "trial-one-unit"):
        block("%s: recommends '%s' while declaring itself quality 'not-safe'" % (label, rec))
        note("efficiency never buys itself with quality; record it as 'hold' instead")

    # 3. Self-report contradiction: the change text names an out-of-scope shape while the
    #    verdict claims no quality cost. Reported, not decided -- a human settles it.
    if verdict in ("neutral", "positive"):
        for pattern, name in OUT_OF_SCOPE:
            if pattern.search(prop["proposed_change"]):
                warn("%s: reads as %s, but declares quality '%s'" % (label, name, verdict))
                note("if the reading is wrong, say in `argument` what the change preserves")
                break

if blocks:
    print("check-proposal: %d blocking finding(s), %d warning(s)" % (blocks, warns), file=sys.stderr)
    sys.exit(1)
if not quiet:
    print("check-proposal: %d proposal(s) checked, %d warning(s)" % (len(data), warns))
sys.exit(0)
