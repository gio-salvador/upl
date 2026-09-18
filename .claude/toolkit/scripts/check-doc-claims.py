#!/usr/bin/env python3
"""Judge documentation's claims about the repository. check-doc-claims.sh owns the explanation
of what this decides and why (single ownership, G59)."""
import os, re, subprocess, sys

root, quiet = sys.argv[1], sys.argv[2] == "1"

def tracked():
    out = subprocess.run(["git", "-C", root, "ls-files", "--cached", "--others",
                          "--exclude-standard"], capture_output=True, text=True)
    return [p for p in out.stdout.splitlines() if p]

files = set(tracked())
dirs = set()
for f in files:
    parts = f.split("/")
    for i in range(1, len(parts)):
        dirs.add("/".join(parts[:i]))
tops = {d for d in dirs if "/" not in d} | {f.split("/")[0] for f in files if "/" in f}

# `sct <subcommand>`: read the dispatch, so the list can never drift from the code.
subcommands = set()
sct = os.path.join(root, "bin", "sct")
if os.path.exists(sct):
    with open(sct, encoding="utf-8") as fh:
        body = fh.read()
    m = re.search(r'^case "\$\{1:-\}" in$(.*?)^esac', body, re.S | re.M)
    if m:
        for line in m.group(1).splitlines():
            cm = re.match(r"\s*([a-z][a-z0-9|-]*)\)\s+\S", line)
            if cm:
                subcommands.update(cm.group(1).split("|"))
    # A check that silently matches nothing PASSES, which is worse than not existing: the first
    # draft's regex missed the dispatch entirely and the subcommand plant sailed through. Fail
    # loudly instead of vacuously (TK-078).
    if not subcommands:
        print("check-doc-claims: found bin/sct but could not read its dispatch; "
              "the subcommand check would pass vacuously", file=sys.stderr)
        sys.exit(2)

basenames = {os.path.basename(f) for f in files}
# Extensions this repository actually uses. A doc naming `scripts/check-plain-language.ts`
# is pointing at ANOTHER repository's gate, and this one has no TypeScript at all; judging
# such a path against these contents reports drift that does not exist.
used_ext = {os.path.splitext(f)[1] for f in files if os.path.splitext(f)[1]}

# The decision log is a historical record, not a description of the repository as it stands.
# It names paths precisely BECAUSE they were wrong, moved, or removed, and correcting it to
# match today would destroy the thing it exists to hold. Append-only history is exempt.
HISTORY = ("docs/decisions/log.md", "CHANGELOG.md")
SPAN = re.compile(r"`([^`\n]{2,120})`")
# A span is a claim about this repository only if it looks like one. Anything holding a
# placeholder, a glob, a shell variable or whitespace is prose, not a path.
SKIP = re.compile(r"[<>*?${}\s|]")

findings = []
for f in sorted(files):
    if not f.endswith(".md") or f in HISTORY:
        continue
    try:
        text = open(os.path.join(root, f), encoding="utf-8").read()
    except (OSError, UnicodeDecodeError):
        continue
    # Fenced blocks are examples and transcripts, not assertions about what exists.
    text = re.sub(r"```.*?```", "", text, flags=re.S)
    for i, line in enumerate(text.splitlines(), 1):
        for span in SPAN.findall(line):
            span = span.strip().rstrip(".,;:)")
            if not span:
                continue

            # 2. a sct subcommand. Judged BEFORE the placeholder filter: every `sct <sub>` span
            # holds a space, so filtering first made this check unreachable and it passed
            # vacuously on a planted `sct frobnicate` (TK-078).
            m = re.match(r"^sct ([a-z][a-z-]*)$", span)
            if m and subcommands:
                if m.group(1) not in subcommands:
                    findings.append((f, i, "names `sct %s`, which is not a subcommand" % m.group(1)))
                continue

            if SKIP.search(span):
                continue

            # `.claude/...` is the namespace a CONSUMING repository declares. A doc naming
            # `.claude/job-fit.yaml` describes what a host must provide, not what exists here,
            # and judging it against this repository's contents is a category error: the first
            # draft produced 30 findings, 28 of them this exact mistake.
            if span.startswith(".claude/"):
                continue

            # 1. a path this repository is said to contain
            if "/" in span and span.split("/")[0] in tops:
                p = span.rstrip("/")
                ext = os.path.splitext(p)[1]
                if ext and ext not in used_ext:
                    continue
                if p not in files and p not in dirs:
                    findings.append((f, i, "names %s, which does not exist" % span))
                continue

            # 3. a bare file name, restricted to this repository's OWN tooling. A doc naming
            # `package.json` or `book.yaml` is describing a host repository; only the gate and
            # schema names are unambiguously ours to check.
            if re.match(r"^check-[a-z0-9-]+\.(sh|py)$|^[a-z0-9-]+\.schema\.json$", span):
                if span not in basenames:
                    findings.append((f, i, "names %s, which is not a file in this repository" % span))

for f, i, msg in findings:
    print("BLOCK  %s:%d: %s" % (f, i, msg), file=sys.stderr)
if findings:
    print("check-doc-claims: %d finding(s); the source defines, the docs are wrong"
          % len(findings), file=sys.stderr)
    sys.exit(1)
if not quiet:
    print("check-doc-claims: every path, subcommand and file name the docs claim exists")
sys.exit(0)
