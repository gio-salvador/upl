#!/usr/bin/env python3
"""Hold the `requires:` block in a skill or agent against what the repository actually contains.

WHY THIS EXISTS. Every tool here depends on other tools: agents it spawns, sibling skills it
invokes, config it reads, a host manifest it expects, binaries it shells out to. Until now every
one of those relationships was PROSE in the SKILL.md, so nothing could compute the closure of a
tool. That blocks importing a named set into a repository we do not own (docs/plans/import-tools.md),
and it means "what breaks if I change this" has no mechanical answer.

WHAT MAKES A DECLARATION WORTH TRUSTING is that it can be wrong and the build says so. Three of
the six keys are checked against the tree:

  skills:   each names skills/<name>/SKILL.md, which must exist
  agents:   each names agents/<name>.md, which must exist
  toolkit:  each path must exist in this repository

and one is checked in the INVERSE direction, which is the interesting one:

  instance: each path must NOT exist in this repository

because `instance:` means overlay data that belongs to one operator and one machine. If
`config/<x>` is present here, the toolkit owns it, it travels with a vendored copy, and calling it
instance data would mislead exactly the reader deciding what can be imported into a client
repository. The distinction is mechanical: the toolkit ships `config/gitops-tiers.json.example`
but never the real file.

  host:     files the CONSUMING repository must provide (e.g. `.claude/docs-sync.yaml`)
  external_repos: another repository entirely, resolved through the instance path registry
  commands: external binaries
  mentions_only: names in the body that were read and judged NOT dependencies

Those three are shape-checked only. A host file cannot be verified from here (that is the host's
business), and asserting a binary exists would make the gate fail on a machine missing an optional
dependency, which is the opposite of degrading cleanly (G44).

AN AGENT IS A DIFFERENT SHAPE. It cannot invoke a skill or spawn another agent: the caller does
that. So `skills:` or `agents:` in an agent's declaration is a claim about something it cannot do
and is a finding, and every `sc-` name in an agent's body is a cross-reference rather than a
dependency, which is why the completeness pass below skips agents entirely.

COMPLETENESS BLOCKS, SINCE 2026-09-01. For skills, the gate holds every `sc-*` name mentioned in a
body against the declaration: it must be a dependency or be listed in `mentions_only`, and saying
which it is, is the whole job. It caught a real omission on its first run, an agent the security
dossier spawns only when a baseline is declared.

It warned rather than blocked while the backfill was in progress, because a gate that fails on
every pre-existing file gets switched off before it can ever be satisfied (TK-093's staged
rollout). All 65 tools now declare, with no outstanding mentions, so the condition the staging
was waiting for is met and the gate is blocking in both directions: a tool with no `requires:`
block at all is a finding, and so is a name that is neither declared nor judged. A graph is only
worth computing over if it is complete.

Usage: check-requires.py <root> <quiet>. Exit 0 clean, 1 finding, 2 cannot run.
"""
import re
import sys
from pathlib import Path

KEYS = ("skills", "agents", "toolkit", "instance", "host", "external_repos",
        "commands", "mentions_only")
SC_NAME = re.compile(r"\bsc-[a-z0-9-]+\b")


def front_matter(text):
    """The YAML block between the first two `---` lines, or None."""
    if not text.startswith("---"):
        return None
    end = text.find("\n---", 3)
    return text[3:end] if end != -1 else None


def parse_requires(fm):
    """The `requires:` mapping as {key: [values]}.

    Deliberately not a YAML parser: the schema keeps this to one nesting level of string lists,
    and the repository already refuses to take a YAML dependency for shapes this simple.
    Returns None when the block is absent, which is "not declared yet" rather than "empty".
    """
    lines = fm.splitlines()
    out, key, seen = {}, None, False
    for raw in lines:
        if re.match(r"^requires:\s*$", raw):
            seen = True
            continue
        if not seen:
            continue
        if raw and not raw[0].isspace():          # back to a top-level key: block is over
            break
        m = re.match(r"^\s{2}([a-z_]+):\s*(.*)$", raw)
        if m:
            key = m.group(1)
            inline = m.group(2).strip()
            if inline.startswith("[") and inline.endswith("]"):
                items = [i.strip().strip("'\"") for i in inline[1:-1].split(",")]
                out[key] = [i for i in items if i]
                key = None
            else:
                out[key] = []
            continue
        m = re.match(r"^\s{4}-\s*(.+?)\s*$", raw)
        if m and key:
            out[key].append(m.group(1).strip("'\""))
    return out if seen else None


def check(root, path, kind, quiet):
    """Findings and warnings for one tool file."""
    findings, warnings = [], []
    text = path.read_text(encoding="utf-8", errors="replace")
    fm = front_matter(text)
    rel = path.relative_to(root)
    if fm is None:
        findings.append(f"{rel}: no front matter, so nothing can declare its dependencies")
        return findings, warnings, False

    req = parse_requires(fm)
    if req is None:
        # BLOCKING SINCE THE BACKFILL COMPLETED. While coverage was partial this was counted and
        # not blocked, because a gate that fails on every pre-existing file gets switched off
        # before it can be satisfied. All 65 tools now declare, so a NEW tool arriving without a
        # declaration is the only way this fires, and it is exactly the drift the gate exists to
        # stop: the graph is only worth computing over if it is complete.
        findings.append(f"{rel}: no requires: block, so nothing declares what it depends on")
        return findings, warnings, False

    for k in req:
        if k not in KEYS:
            findings.append(f"{rel}: requires.{k} is not a declared key ({', '.join(KEYS)})")

    for name in req.get("skills", []):
        if not (root / "skills" / name / "SKILL.md").is_file():
            findings.append(f"{rel}: requires.skills names {name}, which is not a skill here")
    for name in req.get("agents", []):
        if not (root / "agents" / f"{name}.md").is_file():
            findings.append(f"{rel}: requires.agents names {name}, which is not an agent here")
    for p in req.get("toolkit", []):
        if not (root / p).exists():
            findings.append(f"{rel}: requires.toolkit names {p}, which does not exist here")
    for p in req.get("instance", []):
        # The inverse check. A path the toolkit ships is not instance data, and calling it that
        # would mislead whoever is deciding what can travel into a repository we do not own.
        if (root / p).exists():
            findings.append(
                f"{rel}: requires.instance names {p}, which EXISTS here, so the toolkit owns it "
                f"and it travels with a vendored copy: declare it under toolkit")

    # AN AGENT CANNOT INVOKE A SKILL OR SPAWN ANOTHER AGENT. That is a property of the runtime,
    # not a convention, so an agent declaring either is claiming something it cannot do, and every
    # `sc-` name in an agent's body is a cross-reference rather than a dependency. Encoding the
    # rule here is what keeps the completeness warning worth reading: without it, five of the
    # first seven declarations produced warnings that could never be actioned, and a warning
    # nobody can act on is how a check gets ignored.
    if kind == "agent":
        for k in ("skills", "agents"):
            if req.get(k):
                findings.append(
                    f"{rel}: requires.{k} is declared, but an agent cannot invoke a skill or spawn "
                    f"an agent: the caller does that, so the dependency belongs to the caller")
        return findings, warnings, True

    # `mentions_only:` records that a name in the body was READ and judged a cross-reference: a
    # boundary statement ("that belongs to sc-x"), an ancestry note, a manifest example. Without
    # it the completeness pass can never stop warning, because a skill legitimately names the
    # tools either side of it, and a check that always speaks is one nobody reads (G26). It is
    # verified in two directions: the name must resolve, so a tool deleted or renamed cannot sit
    # unnoticed in a cross-reference list, and it must not also be declared a dependency, because
    # "I depend on this" and "I merely mention this" cannot both be true.
    mentions_only = set(req.get("mentions_only", []))
    dependency = set(req.get("skills", [])) | set(req.get("agents", []))
    for name in sorted(mentions_only):
        if not ((root / "skills" / name / "SKILL.md").is_file() or (root / "agents" / f"{name}.md").is_file()):
            findings.append(f"{rel}: requires.mentions_only names {name}, which no longer exists here")
    for name in sorted(mentions_only & dependency):
        findings.append(f"{rel}: {name} is declared both as a dependency and as mentions_only")

    declared = dependency | mentions_only
    body = text[len(fm) + 6:] if fm else text
    own = path.parent.name
    mentioned = {n for n in SC_NAME.findall(body) if n != own}
    for name in sorted(mentioned - declared):
        is_real = (root / "skills" / name / "SKILL.md").is_file() or (root / "agents" / f"{name}.md").is_file()
        if is_real:
            findings.append(
                f"{rel}: mentions {name} but declares it neither as a dependency nor in "
                f"mentions_only: say which it is")
    return findings, warnings, True


def main():
    if len(sys.argv) < 2:
        print("check-requires: need a repository root", file=sys.stderr)
        return 2
    root = Path(sys.argv[1])
    quiet = len(sys.argv) > 2 and sys.argv[2] == "1"
    skills = sorted((root / "skills").glob("*/SKILL.md"))
    agents = sorted(p for p in (root / "agents").glob("*.md") if p.name != "README.md")
    if not skills and not agents:
        print("check-requires: no skills or agents here")
        return 0

    findings, warnings, declared_count = [], [], 0
    for p in skills:
        f, w, d = check(root, p, "skill", quiet)
        findings += f
        warnings += w
        declared_count += 1 if d else 0
    for p in agents:
        f, w, d = check(root, p, "agent", quiet)
        findings += f
        warnings += w
        declared_count += 1 if d else 0

    for f in findings:
        print(f"BLOCK  {f}", file=sys.stderr)
    for w in warnings:
        print(f"warn   {w}", file=sys.stderr)

    total = len(skills) + len(agents)
    if findings:
        print(f"check-requires: {len(findings)} finding(s)", file=sys.stderr)
        return 1
    if not quiet:
        print(f"check-requires: {declared_count}/{total} tools declare their dependencies, "
              f"every declaration holds and every mention is judged")
    return 0


if __name__ == "__main__":
    sys.exit(main())
