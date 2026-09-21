#!/usr/bin/env python3
"""
check-sources.py - the source gate: keeps docs/sources.md, the source register, up to date.

A statement about another tradition, a named figure, a book or a piece of science has to be
traceable. The register holds every outside source used, under a permanent id. This gate makes
sure the register and the pages that lean on it cannot drift apart. The rule and the reasons are
in docs/doctrine-guardrails.md, section 6. Checks:

  1. rows          every row of the register is complete: a unique id in sequence, one link,
                   a kind, what the source supports, where it is used, the date it was read
  2. no loose      an outside link in a teaching or in a page that records checked claims must
     links         be in the register, so a source cannot be used without being recorded
  3. ids resolve   every source id cited anywhere (S07, R04) exists in the register
  4. no orphans    every source in the register is cited by id from at least one other page
  5. used in       every file a row names under "Used in" exists
  6. references    the register's list of the books the teachings cite matches the References
                   page entry for entry, so a change to the bibliography is always re-recorded;
                   an entry taken off the page is retired in the register, never deleted

  scripts/check-sources.py            run the gate
  scripts/check-sources.py --report   also list every source with the pages that cite it

The gate is a floor. It cannot tell whether a source is good or says what the row claims. That
is for the citation and domain-accuracy lenses of the content review, and for the author. It
does not open any link: a gate that needs the network fails for reasons that are not yours.
Sources read more than a year ago are listed as a reminder and never fail the gate.

Pure stdlib. Exit 0 = clean, 1 = problems (one per line), 2 = usage or environment error.
"""
import argparse
import datetime
import re
import sys
from collections import defaultdict
from pathlib import Path

REGISTER = "docs/sources.md"
REFERENCES = "content/5-context/references.md"
# Pages where an outside link is a source for a claim. Other docs link to tools and services.
CLAIM_PAGES = ["content/**/*.md", "docs/doctrine-decisions.md", "docs/site-review.md",
               "docs/doctrine-guardrails.md", "docs/cross-reference.md"]
# Pages searched for cited ids.
CITING_PAGES = ["content/**/*.md", "docs/**/*.md"]
URL_RE = re.compile(r"https?://[^\s)>\]\"']+")
LINK_RE = re.compile(r"\[[^\]]*\]\((https?://[^)\s]+)\)")
ID_RE = re.compile(r"\b([SR]\d{2,3})\b")
CODE_RE = re.compile(r"```.*?```|`[^`\n]*`", re.S)  # a link inside code is an example, not a source
FILE_RE = re.compile(r"\]\(([^)#\s]+)\)|\b([\w./-]+\.md)\b")
STALE_DAYS = 365


def expand(root, patterns):
    found = set()
    for pattern in patterns:
        found.update(p for p in root.glob(pattern) if p.is_file())
    return sorted(found)


def cells(line):
    """The cells of a markdown table row, with a pipe inside a link or code left alone."""
    return [c.strip() for c in re.split(r"(?<!\\)\|", line.strip().strip("|"))]


def parse_register(text):
    """Rows of the two tables: sources (S ids) and the books the teachings cite (R ids)."""
    sources, books = [], []
    for line in text.splitlines():
        if not line.startswith("|"):
            continue
        row = cells(line)
        if re.fullmatch(r"S\d{2,3}", row[0]):
            sources.append(row)
        elif re.fullmatch(r"R\d{2,3}", row[0]):
            books.append(row)
    return sources, books


def reference_entries(text):
    return [line[2:].strip() for line in text.splitlines() if line.startswith("- ")]


def check(root, today):
    problems, notes = [], []
    register_path = root / REGISTER
    register = register_path.read_text(encoding="utf-8")
    sources, books = parse_register(register)
    if not sources:
        return [f"{REGISTER}: no source rows found"], notes, {}

    urls = {}
    for number, row in enumerate(sources, start=1):
        sid = row[0]
        if sid != f"S{number:02d}":
            problems.append(f"{REGISTER}: {sid} is out of sequence, expected S{number:02d}. Ids are permanent: add at the end")
        if len(row) != 6:
            problems.append(f"{REGISTER}: {sid} has {len(row)} cells, needs 6 (id, source, kind, supports, used in, looked at)")
            continue
        _, source, kind, supports, used_in, looked_at = row
        links = LINK_RE.findall(source)
        if len(links) != 1:
            problems.append(f"{REGISTER}: {sid} needs exactly one link in its Source cell")
        for url in links:
            if url in urls:
                problems.append(f"{REGISTER}: {sid} repeats the link of {urls[url]}. One row per source")
            urls[url] = sid
        for name, value in (("Kind", kind), ("Supports", supports), ("Used in", used_in)):
            if not value:
                problems.append(f"{REGISTER}: {sid} has an empty {name} cell")
        try:
            age = (today - datetime.date.fromisoformat(looked_at)).days
            if age < 0:
                problems.append(f"{REGISTER}: {sid} was looked at on {looked_at}, which is in the future")
            elif age > STALE_DAYS:
                notes.append(f"{sid} was last read on {looked_at}; read it again before relying on it")
        except ValueError:
            problems.append(f"{REGISTER}: {sid} needs a Looked at date as YYYY-MM-DD, got \"{looked_at}\"")
        for match in FILE_RE.finditer(used_in):
            name = match.group(1) or match.group(2)
            if name.startswith(("http:", "https:")) or name == "the":
                continue
            if not ((register_path.parent / name).is_file() or (root / name).is_file()):
                problems.append(f"{REGISTER}: {sid} is used in {name}, which does not exist")

    for number, row in enumerate(books, start=1):
        if row[0] != f"R{number:02d}":
            problems.append(f"{REGISTER}: {row[0]} is out of sequence, expected R{number:02d}")
        if len(row) != 3 or not row[1] or not row[2]:
            problems.append(f"{REGISTER}: {row[0]} needs an entry and a standing")

    # 2. No loose links.
    for path in expand(root, CLAIM_PAGES):
        rel = path.relative_to(root).as_posix()
        for url in sorted(set(URL_RE.findall(CODE_RE.sub("", path.read_text(encoding="utf-8"))))):
            if url.rstrip(".,;") not in urls:
                problems.append(f"{rel}: links to {url}, which is not in {REGISTER}. Add a row and cite it by id")

    # 3 and 4. Ids resolve; no orphans.
    known = {row[0] for row in sources} | {row[0] for row in books}
    cited = defaultdict(set)
    for path in expand(root, CITING_PAGES):
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8")
        for sid in ID_RE.findall(text):
            if rel == REGISTER:
                continue
            cited[sid].add(rel)
            if sid not in known:
                problems.append(f"{rel}: cites {sid}, which is not in {REGISTER}")
    # Inside the register, a row may lean on another row.
    for row in sources + books:
        for sid in ID_RE.findall(" ".join(row[1:])):
            if sid not in known:
                problems.append(f"{REGISTER}: {row[0]} cites {sid}, which is not in the register")
            elif sid != row[0]:
                cited[sid].add(REGISTER)
    for row in sources:
        if not cited[row[0]]:
            problems.append(f"{REGISTER}: {row[0]} is cited nowhere. Cite it by id where it is used, or remove the row")

    # 6. The books the teachings cite.
    references = root / REFERENCES
    if references.is_file():
        listed = reference_entries(references.read_text(encoding="utf-8"))
        # A retired row keeps its id and its history, and no longer has to be on the page.
        recorded = [row[1] for row in books if len(row) == 3 and not row[2].startswith("Retired")]
        for row in books:
            if len(row) == 3 and row[2].startswith("Retired") and row[1] in listed:
                problems.append(f"{REGISTER}: {row[0]} is retired but its entry is still in {REFERENCES}")
        for entry in listed:
            if entry not in recorded:
                problems.append(f"{REFERENCES}: the entry {entry} has no row in {REGISTER}. Add one with its standing")
        for entry in recorded:
            if entry not in listed:
                problems.append(f"{REGISTER}: records the entry {entry}, which is no longer in {REFERENCES}. Update the row")
    return problems, notes, cited


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", default=".")
    parser.add_argument("--report", action="store_true")
    parser.add_argument("--today", help=argparse.SUPPRESS)
    args = parser.parse_args()
    root = Path(args.root).resolve()
    if not (root / REGISTER).is_file():
        print(f"check-sources: {REGISTER} is missing", file=sys.stderr)
        return 2
    today = datetime.date.fromisoformat(args.today) if args.today else datetime.date.today()
    problems, notes, cited = check(root, today)
    if args.report:
        for sid in sorted(cited):
            print(f"{sid}: {', '.join(sorted(cited[sid]))}")
    for note in notes:
        print(f"note: {note}")
    for problem in problems:
        print(problem)
    if problems:
        print(f"check-sources: {len(problems)} problem(s). See docs/doctrine-guardrails.md, section 6")
        return 1
    print(f"check-sources: passed ({len(cited)} ids cited, register and References in step)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
