#!/usr/bin/env python3
"""Static posture check of the OpenTofu code under infra/.

General scanners (Trivy, Checkov) ship no rules for the Cloudflare provider, so they cannot
see the things that matter here. This gate holds infra/ to the posture docs/security.md
describes. It reads the files only: no init, no provider download, no credentials.

Usage: check-infra.py [--root infra]
Exit status 0 when every check passes, 1 otherwise.
"""
import argparse
import pathlib
import re
import sys

SECRET_NAME = re.compile(r"token|secret|password|private_key|access_key|account_id", re.I)
# Backend settings that say where the state lives or how to reach it: passed at init time.
BACKEND_NEVER_COMMITTED = ("bucket", "endpoints", "endpoint", "access_key", "secret_key", "token")
# Attributes that carry a credential: they must come from a variable, never from a literal.
CREDENTIAL_ATTRIBUTE = re.compile(r'^\s*(api_token|api_key|access_key|secret_key|password)\s*=\s*"', re.M)


def strip_comments(text):
    """Drop # and // comments, leaving quoted strings alone."""
    out = []
    for line in text.splitlines():
        quoted, i = False, 0
        while i < len(line):
            c = line[i]
            if c == "\\" and quoted:
                i += 2
                continue
            if c == '"':
                quoted = not quoted
            elif not quoted and (c == "#" or line.startswith("//", i)):
                line = line[:i]
                break
            i += 1
        out.append(line)
    return "\n".join(out)


def blocks(text, kind):
    """Yield (labels, body) for each top-level block of the given kind."""
    for m in re.finditer(r'^%s((?:\s+"[^"]*")*)\s*\{' % re.escape(kind), text, re.M):
        depth, i, quoted = 1, m.end(), False
        while i < len(text) and depth:
            c = text[i]
            if c == "\\" and quoted:
                i += 2
                continue
            if c == '"':
                quoted = not quoted
            elif not quoted:
                depth += (c == "{") - (c == "}")
            i += 1
        yield re.findall(r'"([^"]*)"', m.group(1)), text[m.end():i - 1]


def attribute(body, name):
    m = re.search(r"^\s*%s\s*=\s*(.+?)\s*$" % re.escape(name), body, re.M)
    return m.group(1) if m else None


def check(root):
    """Return a list of findings, empty when the posture holds."""
    files = sorted(pathlib.Path(root).glob("*.tf"))
    if not files:
        return ["no .tf files under %s" % root]
    text = "\n".join(strip_comments(f.read_text(encoding="utf-8")) for f in files)
    findings = []

    variables = {labels[0]: body for labels, body in blocks(text, "variable") if labels}
    for name, body in variables.items():
        sensitive = attribute(body, "sensitive") == "true"
        if SECRET_NAME.search(name) and not sensitive:
            findings.append('variable "%s" looks like a secret but is not marked sensitive' % name)
        if sensitive and attribute(body, "default") is not None:
            findings.append('variable "%s" is sensitive and must not have a default' % name)

    for m in CREDENTIAL_ATTRIBUTE.finditer(text):
        findings.append("credential attribute %s is set to a literal; read it from a variable" % m.group(1))

    providers = [body for _, tf in blocks(text, "terraform") for _, body in blocks(dedent(tf), "required_providers")]
    versions = [v for body in providers for v in re.findall(r'^\s*version\s*=\s*"([^"]*)"', body, re.M)]
    if not versions:
        findings.append("no provider version is declared in required_providers")
    for v in versions:
        if not re.fullmatch(r"\d+\.\d+\.\d+", v):
            findings.append('provider version "%s" is a range; pin one exact version' % v)
    if not any(attribute(tf, "required_version") for _, tf in blocks(text, "terraform")):
        findings.append("terraform block declares no required_version")
    if not (pathlib.Path(root) / ".terraform.lock.hcl").is_file():
        findings.append(".terraform.lock.hcl is missing; commit it so provider hashes are pinned")

    for _, tf in blocks(text, "terraform"):
        for _, backend in blocks(dedent(tf), "backend"):
            for key in BACKEND_NEVER_COMMITTED:
                if attribute(backend, key) is not None:
                    findings.append("backend setting %s is committed; pass it at init time" % key)
            if attribute(backend, "use_lockfile") != "true":
                findings.append("backend does not set use_lockfile = true, so state is not locked")

    resources = {tuple(labels): body for labels, body in blocks(text, "resource") if len(labels) == 2}

    def content(kind, name):
        value = attribute(resources.get((kind, name), ""), "content")
        return value.replace('\\"', "").strip('"') if value else None

    dnssec = resources.get(("cloudflare_zone_dnssec", "site"))
    if dnssec is None or attribute(dnssec, "status") != '"active"':
        findings.append("DNSSEC: cloudflare_zone_dnssec.site must exist with status active")
    expectations = [
        ("null_mx", lambda c: c == ".", "null MX: content must be a single dot (RFC 7505)"),
        ("spf", lambda c: c == "v=spf1 -all", "SPF: content must be exactly v=spf1 -all"),
        ("dkim", lambda c: c is not None and re.fullmatch(r"v=DKIM1;\s*p=", c), "DKIM: the wildcard key must be empty"),
        ("dmarc", lambda c: c is not None and "p=reject" in c.split(";")[1] and "sp=reject" in c,
         "DMARC: policy and subdomain policy must both be reject"),
    ]
    for name, ok, message in expectations:
        try:
            passed = ok(content("cloudflare_dns_record", name))
        except (IndexError, AttributeError):
            passed = False
        if not passed:
            findings.append(message)
    for name in ("site_domain_dnssec", "site_domain_no_email"):
        if attribute(variables.get(name, ""), "default") != "true":
            findings.append('variable "%s" must default to true, so the safe posture is the default' % name)
    return findings


def dedent(body):
    """Bring a nested block's children to column 0 so blocks() can find them."""
    lines = body.splitlines()
    indents = [len(l) - len(l.lstrip()) for l in lines if l.strip()]
    cut = min(indents) if indents else 0
    return "\n".join(l[cut:] for l in lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", default="infra")
    args = parser.parse_args()
    findings = check(args.root)
    for f in findings:
        print("check-infra: FAIL  %s" % f)
    if findings:
        return 1
    print("check-infra: passed (secrets, provider pinning, state backend, DNSSEC and no-email posture)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
