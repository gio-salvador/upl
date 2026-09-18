#!/usr/bin/env python3
"""
check-content-index.py - the cross-reference gate for the teachings under content/.

scripts/content-index.json is the index of the teachings: which page owns each concept, where
the concept is elaborated, which pages are current or deprecated, and the register of known
overlaps (redundant, ambiguous, conflicting, deprecated). docs/cross-reference.md is the
readable view, written by this script. The reasons are in docs/cross-reference.md itself.

What is kept by hand is small on purpose: the concepts, the page status and the findings. Where
a concept is mentioned is worked out from the text on every run, so it cannot go stale.

Checks:

  1. coverage      every page under content/ is in the index, and nothing in the index is gone
  2. freshness     every page matches its recorded fingerprint, so a changed page is always
                   re-read against the index before it merges
  3. ownership     every concept has one owner page, current, that names the concept; the pages
                   said to elaborate it exist and name it too
  4. lifecycle     a deprecated page names its replacement, owns nothing, and no current page
                   links to it
  5. ambiguity     two current pages with the same title need a finding that covers both
  6. redundancy    two pages that share a run of identical wording need a finding that covers
                   both
  7. findings      every finding is well formed and points at files that exist
  8. rendering     docs/cross-reference.md matches the index

  scripts/check-content-index.py            run the gate
  scripts/check-content-index.py --record   after re-reading the changed pages against the
                                            index: stamp their fingerprints, write the view
  scripts/check-content-index.py --render   write docs/cross-reference.md only

--record is not a way to make the gate pass. It states that the changed pages were checked
against the concepts and findings, and that the index was updated where they touch it.

The gate is a floor. It matches words; it cannot tell whether two pages disagree. Conflicts are
found by reading, and recorded as findings. Open conflicts are printed on every run.

Pure stdlib. Exit 0 = clean, 1 = problems (one per line), 2 = usage or environment error.
"""
import argparse
import hashlib
import json
import re
import sys
from collections import defaultdict
from itertools import combinations
from pathlib import Path

INDEX = "scripts/content-index.json"
VIEW = "docs/cross-reference.md"
SCAN = "content/**/*.md"
FRONT_MATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.S)
TITLE_RE = re.compile(r'^title:\s*"?(.*?)"?\s*$', re.M)
LINK_RE = re.compile(r"\]\(([^)#\s]+)(?:#[^)]*)?\)")
LINK_TARGET_RE = re.compile(r"\]\([^)]*\)")
WORD_RE = re.compile(r"[a-z0-9']+")
FINDING_TYPES = ("redundant", "ambiguous", "conflicting", "deprecated")
FINDING_STATUS = ("open", "accepted", "resolved")
PAGE_STATUS = ("current", "deprecated")
SHINGLE = 8       # words in a run of identical wording
SHARED_RUNS = 3   # this many shared runs between two pages is a redundancy to record


def fingerprint(text):
    """Hash of the page with trailing whitespace ignored, so only a change of text counts."""
    lines = [line.rstrip() for line in text.strip().splitlines()]
    return hashlib.sha256("\n".join(lines).encode("utf-8")).hexdigest()


def title_of(text):
    front = FRONT_MATTER_RE.match(text)
    found = TITLE_RE.search(front.group(1)) if front else None
    return found.group(1) if found else ""


def prose(text):
    """The words a reader sees, title included: no other front matter, no link targets."""
    body = LINK_TARGET_RE.sub("]", FRONT_MATTER_RE.sub("", text, count=1))
    return f"{title_of(text)}\n{body}"


def shingles(text):
    """Runs of SHINGLE words from the body, headings and lists left out: they repeat by design."""
    body = FRONT_MATTER_RE.sub("", text, count=1)
    lines = [ln for ln in body.splitlines() if ln.strip() and not re.match(r"\s*(#|\d+\.|[-*]\s)", ln)]
    words = WORD_RE.findall(LINK_TARGET_RE.sub("]", " ".join(lines)).lower())
    return {" ".join(words[i:i + SHINGLE]) for i in range(len(words) - SHINGLE + 1)}


def load_pages(root):
    return {p.relative_to(root).as_posix(): p.read_text(encoding="utf-8") for p in sorted(root.glob(SCAN))}


def mentions(index, pages):
    """concept id -> {page: count}, worked out from the text."""
    found = defaultdict(dict)
    for cid, concept in index["concepts"].items():
        pattern = re.compile(r"\b(?:" + "|".join(concept["terms"]) + r")\b", re.I)
        for path, text in pages.items():
            count = len(pattern.findall(prose(text)))
            if count:
                found[cid][path] = count
    return found


def covered(index, kinds, *paths):
    """True when one finding of one of these kinds names all of these pages."""
    return any(f.get("type") in kinds and set(paths) <= set(f.get("pages", [])) for f in index["findings"])


def check(root, index, pages):
    problems = []
    entries = index["pages"]
    concepts = index["concepts"]

    for path in pages:
        if path not in entries:
            problems.append(f"{path}: not in {INDEX}. Add it, give its concepts an owner, then --record")
    for path in entries:
        if path not in pages:
            problems.append(f"{INDEX}: lists {path}, which no longer exists. Remove it or mark its replacement")

    for path, text in pages.items():
        entry = entries.get(path)
        if not entry:
            continue
        if entry.get("status") not in PAGE_STATUS:
            problems.append(f"{path}: status must be one of {', '.join(PAGE_STATUS)}")
        if entry.get("fingerprint") != fingerprint(text):
            problems.append(f"{path}: changed since the index was last recorded. Re-read it against "
                            f"{VIEW}, update {INDEX} where it touches a concept or a finding, then --record")

    found = mentions(index, pages)
    for cid, concept in concepts.items():
        try:
            re.compile("|".join(concept["terms"]))
        except re.error as err:
            problems.append(f"concept {cid}: bad term pattern: {err}")
            continue
        owner = concept.get("owner")
        for role, path in [("owner", owner)] + [("elaborated_in", p) for p in concept.get("elaborated_in", [])]:
            if path not in pages:
                problems.append(f"concept {cid}: {role} {path} does not exist")
            elif path not in found[cid]:
                problems.append(f"concept {cid}: {role} {path} never names the concept")
            elif entries.get(path, {}).get("status") == "deprecated":
                problems.append(f"concept {cid}: {role} {path} is deprecated. Move the concept to a current page")

    for path, entry in entries.items():
        if entry.get("status") != "deprecated" or path not in pages:
            continue
        target = entry.get("replaced_by")
        if target not in pages or entries.get(target, {}).get("status") != "current":
            problems.append(f"{path}: deprecated pages must name a current page in replaced_by")
        for other, text in pages.items():
            if other == path or entries.get(other, {}).get("status") == "deprecated":
                continue
            base = Path(other).parent
            for link in LINK_RE.findall(text):
                if not link.startswith(("http:", "https:", "mailto:")) and \
                        (root / base / link).resolve() == (root / path).resolve():
                    problems.append(f"{other}: links to deprecated page {path}")

    current = [p for p in pages if entries.get(p, {}).get("status") != "deprecated"]
    by_title = defaultdict(list)
    for path in current:
        by_title[title_of(pages[path]).strip().lower()].append(path)
    for title, paths in by_title.items():
        for a, b in combinations(paths, 2):
            if not covered(index, ("ambiguous",), a, b):
                problems.append(f"{a} and {b}: same title \"{title}\". Rename one or record an ambiguous finding")

    runs = {p: shingles(pages[p]) for p in current}
    for a, b in combinations(current, 2):
        shared = len(runs[a] & runs[b])
        if shared >= SHARED_RUNS and not covered(index, ("redundant",), a, b):
            example = sorted(runs[a] & runs[b])[0]
            problems.append(f"{a} and {b}: share {shared} runs of identical wording (\"{example}...\"). "
                            "Keep it in one place or record a redundant finding")

    seen = set()
    for f in index["findings"]:
        fid = f.get("id", "?")
        if fid in seen:
            problems.append(f"finding {fid}: id used twice")
        seen.add(fid)
        if f.get("type") not in FINDING_TYPES:
            problems.append(f"finding {fid}: type must be one of {', '.join(FINDING_TYPES)}")
        if f.get("status") not in FINDING_STATUS:
            problems.append(f"finding {fid}: status must be one of {', '.join(FINDING_STATUS)}")
        if not f.get("note") or len(f.get("pages", [])) < 1:
            problems.append(f"finding {fid}: needs a note and at least one page")
        if f.get("status") == "accepted" and not f.get("reason"):
            problems.append(f"finding {fid}: an accepted finding needs a reason")
        for path in f.get("pages", []):
            if not (root / path).is_file():
                problems.append(f"finding {fid}: {path} does not exist")
        if f.get("concept") and f["concept"] not in concepts:
            problems.append(f"finding {fid}: unknown concept {f['concept']}")
    return problems


def short(path):
    return path.removeprefix("content/").removesuffix(".md").removesuffix("/README")


def link(path):
    return f"[{short(path)}](../{path})"


def row(*cells):
    """A table row in markdownlint's compact style: an empty cell is a single space."""
    return "|" + "|".join(f" {c} " if c else " " for c in cells) + "|"


def render(index, pages):
    found = mentions(index, pages)
    parts = sorted({p.split("/")[1] for p in pages if p.count("/") > 1})
    out = [
        "# Cross-reference matrix",
        "",
        "The index of the teachings: which page owns each concept, where it is elaborated, where it",
        "is mentioned, and the known overlaps between pages. For anyone adding or changing a page",
        "under `content/`, so that the text does not grow ambiguous, redundant, deprecated or",
        "conflicting content.",
        "",
        "This page is written by `scripts/check-content-index.py --render` from",
        "`scripts/content-index.json`. Do not edit it by hand.",
        "",
        "## How it works",
        "",
        "- **One owner per concept.** The owner page is where the concept is stated. Other pages may",
        "  elaborate it or mention it; they should not restate it, and must not contradict it.",
        "- **Mentions are worked out, not written down.** The script finds them from each concept's",
        "  terms on every run, so this part of the matrix cannot go stale.",
        "- **Every page has a status**, `current` or `deprecated`. A deprecated page names its",
        "  replacement, owns nothing, and no current page may link to it.",
        "- **Overlaps are recorded as findings**, each with a type, a status and a note. `open` means",
        "  undecided, `accepted` means kept on purpose with a reason, `resolved` means fixed.",
        "- **Every page is fingerprinted.** A changed or new page fails `scripts/check.sh` until it",
        "  has been re-read against this matrix and recorded, so the matrix is updated before any",
        "  merge.",
        "",
        "## Before you merge a change under `content/`",
        "",
        "1. Find the concepts your page touches in the table below and read their owner pages.",
        "2. If your page states a concept that already has an owner, link to the owner instead, or",
        "   move ownership on purpose.",
        "3. A new concept gets an entry in `scripts/content-index.json` with one owner and its terms.",
        "4. Record any overlap you leave in place as a finding. Close the findings you fix.",
        "5. Run `python3 scripts/check-content-index.py --record`, then `bash scripts/check.sh`.",
        "",
        "## Concepts",
        "",
        "Counts are the number of pages in each part that name the concept.",
        "",
        "| Concept | Owner | Elaborated in | " + " | ".join(p.split("-", 1)[1] for p in parts) + " | Pages |",
        "| ------- | ----- | ------------- | " + " | ".join("---:" for _ in parts) + " | ----: |",
    ]
    for cid, concept in index["concepts"].items():
        hits = found[cid]
        per_part = [str(sum(1 for p in hits if p.split("/")[1] == part) or "") for part in parts]
        elaborated = ", ".join(link(p) for p in concept.get("elaborated_in", []))
        out.append(row(concept["label"], link(concept["owner"]), elaborated, *per_part, str(len(hits))))

    out += ["", "## Findings", ""]
    for status in FINDING_STATUS:
        rows = [f for f in index["findings"] if f["status"] == status]
        if not rows:
            continue
        out += [f"### {status.capitalize()}", "", "| Id | Type | Pages | Note |", "| -- | ---- | ----- | ---- |"]
        for f in rows:
            where = ", ".join(link(p) if p.startswith("content/") else f"`{p}`" for p in f["pages"])
            note = f["note"] + (f" Reason kept: {f['reason']}" if f.get("reason") else "")
            out.append(row(f["id"], f["type"], where, note))
        out.append("")

    out += ["## Pages", "", "| Page | Status | Owns | Also names |", "| ---- | ------ | ---- | ---------- |"]
    labels = {cid: c["label"] for cid, c in index["concepts"].items()}
    for path in pages:
        entry = index["pages"].get(path, {})
        owns = [labels[c] for c, v in index["concepts"].items() if v["owner"] == path]
        names = [labels[c] for c in index["concepts"] if path in found[c] and labels[c] not in owns]
        status = entry.get("status", "?") + (f", see {link(entry['replaced_by'])}" if entry.get("replaced_by") else "")
        out.append(row(link(path), status, ", ".join(owns), ", ".join(names)))
    return "\n".join(out) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", default=".")
    parser.add_argument("--record", action="store_true")
    parser.add_argument("--render", action="store_true")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    index_path = root / INDEX
    if not index_path.exists():
        print(f"check-content-index: {INDEX} is missing", file=sys.stderr)
        return 2
    try:
        index = json.loads(index_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as err:
        print(f"check-content-index: {INDEX} is not valid JSON: {err}", file=sys.stderr)
        return 2
    pages = load_pages(root)

    if args.record:
        for path, text in pages.items():
            entry = index["pages"].setdefault(path, {"status": "current"})
            entry["fingerprint"] = fingerprint(text)
        index["pages"] = {p: index["pages"][p] for p in sorted(index["pages"]) if p in pages}
        index_path.write_text(json.dumps(index, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if args.record or args.render:
        (root / VIEW).write_text(render(index, pages), encoding="utf-8")

    problems = check(root, index, pages)
    view = root / VIEW
    if not view.exists() or view.read_text(encoding="utf-8") != render(index, pages):
        problems.append(f"{VIEW}: out of date. Run scripts/check-content-index.py --render")

    for f in index["findings"]:
        if f.get("status") == "open" and f.get("type") == "conflicting":
            print(f"open conflict {f['id']}: {f['note']}")
    for problem in problems:
        print(problem)
    if problems:
        print(f"check-content-index: {len(problems)} problem(s)")
        return 1
    print(f"check-content-index: {len(pages)} pages, {len(index['concepts'])} concepts, "
          f"{sum(1 for f in index['findings'] if f['status'] == 'open')} open finding(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
