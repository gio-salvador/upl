#!/usr/bin/env python3
"""
check-docs.py - generic documentation gate for any repo in the fleet.

Deterministic checks, per the standard in ~/.claude/config/docs/standard.md:
  1. the root README exists, has an H1, and links to the docs index
  2. the docs root and the index exist; every --require page exists, is
     non-empty, has an H1, and carries no TODO(docs-sync) markers
  3. skills/agents parity: every <skills-dir>/<name>/SKILL.md has a
     <reference-root>/skills/<name>.md, every <agents-dir>/<name>.md has a
     <reference-root>/agents/<name>.md (absent source dirs = zero sets, fine)
  4. no orphan reference docs (doc present, source gone)
  5. every relative .md link (and its #anchor), and every relative
     directory-target link (target ending in "/"), in the readme, docs root,
     reference root, and source dirs resolves (approximate GitHub slug rules
     for anchors)
  6. kebab-case naming for .md files under the docs root (uppercase allowlist:
     README.md, SECURITY.md, CONTRIBUTING.md; --no-naming skips)
  7. balanced ``` fences (an odd count means an unterminated block)

Files are enumerated via `git ls-files --cached --others --exclude-standard`,
so gitignored files and submodule contents never participate.

Callers (the sc-docs-sync skill, the sc-docs-auditor agent) pass resolved
manifest values as flags; this script reads no YAML. --exclude globs are
relative to the docs root; excluded files skip the naming and fence checks but
their links are still checked. A repo wanting this gate in CI commits its own
copy and names it in the manifest's `parity_check`, which then takes
precedence over this shipped copy.

Pure stdlib. Exit 0 = clean, 1 = problems (listed one per line),
2 = usage or environment error.
"""
import argparse
import fnmatch
import re
import subprocess
import sys
from pathlib import Path

FILE_LINK_RE = re.compile(r"\]\(([^)\s#]+\.md)(#[^)\s]*)?\)")
DIR_LINK_RE = re.compile(r"\]\(([^)\s#]+/)(#[^)\s]*)?\)")
ANCHOR_LINK_RE = re.compile(r"\]\((#[^)\s]+)\)")
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)$")
HTML_ANCHOR_RE = re.compile(r"(?:id|name)=[\"']([^\"']+)[\"']")
KEBAB_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*\.md$")
NAMING_ALLOWLIST = {"README.md", "SECURITY.md", "CONTRIBUTING.md"}


def parse_args(argv):
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--root", required=True, help="repo root (must be a git repo)")
    p.add_argument("--skills-dir", default=".claude/skills")
    p.add_argument("--agents-dir", default=".claude/agents")
    p.add_argument("--rules-dir", default=".claude/rules",
                   help="rule sources mirrored to <reference-root>/rules/ when present")
    p.add_argument("--docs-root", default="docs")
    p.add_argument("--reference-root", default=None,
                   help="where skills/ + agents/ mirror pages live (default: docs root)")
    p.add_argument("--index", default=None,
                   help="docs index page (default: <docs-root>/README.md)")
    p.add_argument("--readme", default="README.md")
    p.add_argument("--require", action="append", default=[], metavar="ROLE=RELPATH",
                   help="required page, path relative to the docs root (repeatable)")
    p.add_argument("--exclude", action="append", default=[], metavar="GLOB",
                   help="glob relative to the docs root to skip naming/fence checks (repeatable)")
    p.add_argument("--no-naming", action="store_true", help="skip the kebab-case naming check")
    return p.parse_args(argv)


def git_files(root: Path):
    out = subprocess.run(
        ["git", "-C", str(root), "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
        capture_output=True, text=True)
    if out.returncode != 0:
        return None
    return {f for f in out.stdout.split("\0") if f and (root / f).is_file()}


def strip_code(text: str):
    """Blank out fenced code blocks and inline code spans so their contents are
    never parsed as links or headings (fence balance is checked on raw text)."""
    out, in_fence = [], False
    for line in text.splitlines():
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            out.append("")
            continue
        out.append("" if in_fence else line)
    return re.sub(r"`[^`\n]*`", "", "\n".join(out))


def heading_slugs(text: str):
    """Approximate GitHub heading slugs, plus explicit HTML id=/name= anchors."""
    slugs, seen = set(), {}
    for line in strip_code(text).splitlines():
        m = HEADING_RE.match(line)
        if not m:
            continue
        h = re.sub(r"`([^`]*)`", r"\1", m.group(2))
        h = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", h)
        s = re.sub(r"[^\w\s-]", "", h.lower().strip())
        s = re.sub(r"\s", "-", s)
        n = seen.get(s, 0)
        seen[s] = n + 1
        slugs.add(s if n == 0 else f"{s}-{n}")
    slugs.update(a.lower() for a in HTML_ANCHOR_RE.findall(text))
    return slugs


def anchor_ok(anchor: str, slugs: set):
    a = anchor.lstrip("#").lower()
    if a in slugs:
        return True
    collapse = re.sub(r"-+", "-", a)
    return any(re.sub(r"-+", "-", s) == collapse for s in slugs)


def has_h1(text: str):
    return any(re.match(r"^#\s+\S", line) for line in strip_code(text).splitlines())


def excluded(rel_to_docs: str, globs):
    for g in globs:
        if g.endswith("/**") and (rel_to_docs == g[:-3] or rel_to_docs.startswith(g[:-3] + "/")):
            return True
        if fnmatch.fnmatch(rel_to_docs, g):
            return True
    return False


def main(argv=None):
    a = parse_args(argv)
    root = Path(a.root).expanduser().resolve()
    if not root.is_dir():
        print(f"check-docs: --root {a.root} is not a directory", file=sys.stderr)
        return 2
    files = git_files(root)
    if files is None:
        print(f"check-docs: {root} is not a git repository (git ls-files failed)", file=sys.stderr)
        return 2

    docs_root = a.docs_root.rstrip("/")
    ref_root = (a.reference_root or docs_root).rstrip("/")
    index = a.index or f"{docs_root}/README.md"
    required = {}
    for item in a.require:
        if "=" not in item:
            print(f"check-docs: bad --require '{item}' (expected ROLE=RELPATH)", file=sys.stderr)
            return 2
        role, rel = item.split("=", 1)
        required[role] = f"{docs_root}/{rel}"

    problems = []
    read = lambda rel: (root / rel).read_text(encoding="utf-8", errors="replace")

    # 1. root README: exists, H1, links to the docs index
    if a.readme not in files:
        problems.append(f"missing root README: {a.readme}")
    else:
        text = read(a.readme)
        if not has_h1(text):
            problems.append(f"{a.readme}: no H1 heading")
        index_abs = (root / index).resolve()
        linked = any(((root / a.readme).parent / m.group(1).split(":")[0]).resolve() == index_abs
                     for m in FILE_LINK_RE.finditer(strip_code(text)))
        if not linked:
            problems.append(f"{a.readme}: does not link to the docs index ({index})")

    # 2. docs root, index, required pages
    if not (root / docs_root).is_dir():
        problems.append(f"missing docs root: {docs_root}/")
    for role, rel in [("index", index)] + sorted(required.items()):
        if rel not in files:
            problems.append(f"missing required page ({role}): {rel}")
            continue
        text = read(rel)
        if not text.strip():
            problems.append(f"{rel}: required page ({role}) is empty")
        elif not has_h1(text):
            problems.append(f"{rel}: no H1 heading")
        if "TODO(docs-sync)" in text:
            problems.append(f"{rel}: unresolved TODO(docs-sync) marker")

    # 3 + 4. skills/agents/rules parity, orphans, and the per-directory index.
    # Each mirrored category is conditional: an absent source dir is a zero set, not an
    # error. A populated reference subdirectory carries its own README.md index, which is
    # excluded from the per-item sets (it is the index, not an item).
    def docs_in(sub):
        return {m.group(1) for f in files
                if (m := re.fullmatch(re.escape(ref_root) + rf"/{sub}/([^/]+)\.md", f))
                and m.group(1) != "README"}

    skills = {m.group(1) for f in files
              if (m := re.fullmatch(re.escape(a.skills_dir) + r"/([^/]+)/SKILL\.md", f))}
    agents = {m.group(1) for f in files
              if (m := re.fullmatch(re.escape(a.agents_dir) + r"/([^/]+)\.md", f))}
    rules = {m.group(1) for f in files
             if (m := re.fullmatch(re.escape(a.rules_dir) + r"/([^/]+)\.md", f))}
    for noun, sub, srcs in (("skill", "skills", skills),
                            ("agent", "agents", agents),
                            ("rule", "rules", rules)):
        docs = docs_in(sub)
        for missing in sorted(srcs - docs):
            problems.append(f"{noun} '{missing}' has no {ref_root}/{sub}/{missing}.md")
        for orphan in sorted(docs - srcs):
            problems.append(f"orphan doc {ref_root}/{sub}/{orphan}.md (no matching {noun})")
        if srcs or docs:
            idx = f"{ref_root}/{sub}/README.md"
            if idx not in files:
                problems.append(f"missing {sub} index: {idx}")
            else:
                itext = read(idx)
                if not itext.strip():
                    problems.append(f"{idx}: {sub} index is empty")
                elif not has_h1(itext):
                    problems.append(f"{idx}: no H1 heading")

    # 5 + 6 + 7. links, naming, fences over the managed scope
    scope_prefixes = tuple(dict.fromkeys(
        d + "/" for d in (docs_root, ref_root, a.skills_dir, a.agents_dir, a.rules_dir)))
    scope = {f for f in files if f.endswith(".md") and f.startswith(scope_prefixes)}
    scope.add(a.readme) if a.readme in files else None
    links_checked = 0
    for rel in sorted(scope):
        text = read(rel)
        prose = strip_code(text)
        under_docs = rel.startswith(docs_root + "/")
        rel_to_docs = rel[len(docs_root) + 1:] if under_docs else ""
        is_excluded = under_docs and excluded(rel_to_docs, a.exclude)

        for m in FILE_LINK_RE.finditer(prose):
            link, anchor = m.group(1), m.group(2)
            if link.startswith(("http://", "https://", "/")):
                continue
            links_checked += 1
            target = ((root / rel).parent / link.split(":")[0]).resolve()
            if not target.is_file():
                problems.append(f"{rel} -> broken link {link}")
            elif anchor and not anchor_ok(anchor, heading_slugs(
                    target.read_text(encoding="utf-8", errors="replace"))):
                problems.append(f"{rel} -> unresolved anchor {link}{anchor}")
        for m in DIR_LINK_RE.finditer(prose):
            link = m.group(1)
            if link.startswith(("http://", "https://", "/")):
                continue
            links_checked += 1
            target = ((root / rel).parent / link).resolve()
            if not target.is_dir():
                problems.append(f"{rel} -> broken directory link {link}")
        for m in ANCHOR_LINK_RE.finditer(prose):
            links_checked += 1
            if not anchor_ok(m.group(1), heading_slugs(text)):
                problems.append(f"{rel} -> unresolved in-page anchor {m.group(1)}")

        if is_excluded:
            continue
        name = rel.rsplit("/", 1)[-1]
        if (under_docs and not a.no_naming
                and name not in NAMING_ALLOWLIST and not KEBAB_RE.fullmatch(name)):
            problems.append(f"{rel}: file name is not kebab-case")
        if sum(1 for line in text.splitlines() if line.lstrip().startswith("```")) % 2:
            problems.append(f"{rel}: unbalanced ``` fence")

    if problems:
        print(f"docs check: {len(problems)} problem(s)")
        for p in problems:
            print(f"  {p}")
        return 1
    print(f"docs check: clean. skills={len(skills)} agents={len(agents)} "
          f"rules={len(rules)} pages={len(scope)} links={links_checked}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
