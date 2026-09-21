#!/usr/bin/env python3
"""
check-doctrine.py - the doctrine gate for the teachings under content/.

It holds new and changed pages to the core beliefs and to a balance between the traditions the
teachings draw on. The rules and the reasons are in docs/doctrine-guardrails.md. Four checks:

  1. contrary language   wording that contradicts a core belief outright (exclusive truth,
                         ranking of traditions, scriptural literalism, and so on)
  2. page balance        a page that leans on one tradition alone, or mostly on one
  3. section and corpus  one tradition carrying too large a share of a section or of the whole
     balance             text; an imbalance already recorded may shrink but never grow
  4. core lock           the foundations and doctrine pages match the recorded text, so a change
                         to a core belief is always declared and never a side effect

An existing imbalance is recorded in doctrine-baseline.json against the exact text of the page.
Editing that page voids the record, so an updated page has to come into balance.

  scripts/check-doctrine.py                   run the gate
  scripts/check-doctrine.py --report          also print the mentions per page, how many traditions
                                              each part names, and which tradition each core
                                              belief names first
  scripts/check-doctrine.py --accept-core     record the current core pages (author's decision)
  scripts/check-doctrine.py --waive-imbalance record the current imbalances (author's decision)

The gate is a floor. It counts words and matches patterns; it cannot tell whether a page is true
to the teachings. That judgement belongs to the review lens and to the author.

Pure stdlib. Exit 0 = clean, 1 = problems (one per line), 2 = usage or environment error.
"""
import argparse
import hashlib
import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

CONFIG = "scripts/doctrine-gate.json"
BASELINE = "scripts/doctrine-baseline.json"
FRONT_MATTER_RE = re.compile(r"\A---\n.*?\n---\n", re.S)
LINK_TARGET_RE = re.compile(r"\]\([^)]*\)")
EPSILON = 1e-9


def load_json(path, default=None):
    if not path.exists():
        if default is None:
            sys.exit(f"check-doctrine: {path} is missing")
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as err:
        sys.exit(f"check-doctrine: {path} is not valid JSON: {err}")


def expand(root, patterns):
    found = set()
    for pattern in patterns:
        found.update(p for p in root.glob(pattern) if p.is_file())
    return sorted(found)


def fingerprint(text):
    """Hash of the page with trailing whitespace ignored, so only a change of text counts."""
    lines = [line.rstrip() for line in text.strip().splitlines()]
    return hashlib.sha256("\n".join(lines).encode("utf-8")).hexdigest()


def prose(text):
    """The words a reader sees: no front matter, no link targets."""
    return LINK_TARGET_RE.sub("]", FRONT_MATTER_RE.sub("", text, count=1))


def compile_traditions(config):
    return {
        name: re.compile(r"\b(?:" + "|".join(markers) + r")\b", re.I)
        for name, markers in config["traditions"].items()
    }


def count_mentions(text, traditions):
    counts = Counter()
    for name, pattern in traditions.items():
        hits = len(pattern.findall(text))
        if hits:
            counts[name] = hits
    return counts


def dominant(counts):
    """The most mentioned tradition and its share of all mentions."""
    total = sum(counts.values())
    name, hits = counts.most_common(1)[0]
    return name, hits / total, total


def percent(share):
    return f"{share * 100:.0f}%"


def check_contrary(rel, text, config, problems):
    excused = {(e["file"], e["id"]) for e in config.get("exceptions", [])}
    rules = [(r["id"], r["belief"], re.compile(r["pattern"], re.I)) for r in config["contrary"]]
    for number, line in enumerate(text.splitlines(), 1):
        for rule_id, belief, pattern in rules:
            match = pattern.search(line)
            if match and (rel, rule_id) not in excused:
                problems.append(
                    f"{rel}:{number}: contrary language [{rule_id}]: \"{match.group(0)}\" "
                    f"contradicts the teaching on {belief}"
                )


def page_violation(counts, balance):
    """Why this page is out of balance, or None."""
    if not counts:
        return None
    name, share, total = dominant(counts)
    if len(counts) == 1:
        return name, f"names {name} and no other tradition"
    if total >= balance["page_min_mentions"] and share > balance["page_cap"] + EPSILON:
        return name, (f"{name} carries {percent(share)} of the mentions of a tradition "
                      f"(cap {percent(balance['page_cap'])})")
    return None


def share_violation(counts, cap, minimum):
    if not counts:
        return None
    name, share, total = dominant(counts)
    if total >= minimum and share > cap + EPSILON:
        return name, share
    return None


def check_ratchet(label, where, violation, recorded, cap, problems, notes):
    """A recorded imbalance may shrink but never grow, and a cleared one must be removed."""
    if violation is None:
        if recorded:
            problems.append(f"{label}: the recorded imbalance is cleared; remove it from "
                            f"{BASELINE} with --waive-imbalance")
        return
    name, share = violation
    if not recorded:
        problems.append(f"{label}: {name} carries {percent(share)} of the mentions of a "
                        f"tradition in {where} (cap {percent(cap)})")
    elif recorded["tradition"] != name or share > recorded["share"] + EPSILON:
        problems.append(f"{label}: the imbalance grew: {name} now carries {percent(share)} of "
                        f"the mentions in {where}, recorded {recorded['tradition']} at "
                        f"{percent(recorded['share'])}")
    else:
        notes.append(f"{label}: known imbalance, {name} at {percent(share)} "
                     f"(cap {percent(cap)})")


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", default=".", help="repository root")
    parser.add_argument("--report", action="store_true", help="print the mentions per page")
    parser.add_argument("--accept-core", action="store_true",
                        help="record the current core pages in the baseline")
    parser.add_argument("--waive-imbalance", action="store_true",
                        help="record the current imbalances in the baseline")
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    config = load_json(root / CONFIG)
    baseline = load_json(root / BASELINE, default={})
    for key in ("core", "pages", "sections"):
        baseline.setdefault(key, {})
    baseline.setdefault("corpus", None)

    balance = config["balance"]
    traditions = compile_traditions(config)
    dedicated = config.get("dedicated", {})
    problems, notes = [], []

    pages = {}
    for path in expand(root, config["scan"]):
        rel = path.relative_to(root).as_posix()
        text = path.read_text(encoding="utf-8")
        pages[rel] = (text, fingerprint(text), count_mentions(prose(text), traditions))
    if not pages:
        sys.exit("check-doctrine: no pages matched the scan patterns")

    for rel, tradition in dedicated.items():
        if rel not in pages:
            problems.append(f"{CONFIG}: dedicated page {rel} does not exist")
        elif tradition not in traditions:
            problems.append(f"{CONFIG}: dedicated page {rel} names an unknown tradition")

    # 1 and 2: contrary language and page balance
    page_found = {}
    by_section, corpus = defaultdict(Counter), Counter()
    for rel, (text, digest, counts) in pages.items():
        check_contrary(rel, text, config, problems)
        if rel in dedicated:
            continue
        by_section[str(Path(rel).parent)].update(counts)
        corpus.update(counts)
        found = page_violation(counts, balance)
        recorded = baseline["pages"].get(rel)
        if found:
            page_found[rel] = {"tradition": found[0], "sha256": digest}
            if not recorded:
                problems.append(f"{rel}: out of balance: {found[1]}")
            elif recorded["sha256"] != digest:
                problems.append(f"{rel}: this page changed and is still out of balance: "
                                f"{found[1]}. A changed page has to come into balance")
            else:
                notes.append(f"{rel}: known imbalance, {found[1]}")
        elif recorded:
            problems.append(f"{rel}: the recorded imbalance is cleared; remove it from "
                            f"{BASELINE} with --waive-imbalance")
    for rel in baseline["pages"]:
        if rel not in pages:
            problems.append(f"{BASELINE}: recorded page {rel} does not exist")

    # 3: section and corpus balance
    section_found = {}
    for section in sorted(set(by_section) | set(baseline["sections"])):
        found = share_violation(by_section.get(section, Counter()), balance["section_cap"],
                                balance["section_min_mentions"])
        if found:
            section_found[section] = {"tradition": found[0], "share": round(found[1], 4)}
        check_ratchet(section, "this section", found, baseline["sections"].get(section),
                      balance["section_cap"], problems, notes)
    corpus_violation = share_violation(corpus, balance["corpus_cap"], 1)
    corpus_found = None
    if corpus_violation:
        corpus_found = {"tradition": corpus_violation[0], "share": round(corpus_violation[1], 4)}
    check_ratchet("content", "the whole text", corpus_violation, baseline["corpus"],
                  balance["corpus_cap"], problems, notes)

    # 4: core lock
    core_found = {}
    for path in expand(root, config["core"]):
        rel = path.relative_to(root).as_posix()
        core_found[rel] = fingerprint(path.read_text(encoding="utf-8"))
    for rel, digest in core_found.items():
        recorded = baseline["core"].get(rel)
        if recorded is None:
            problems.append(f"{rel}: a new core page. The author records it with --accept-core")
        elif recorded != digest:
            problems.append(f"{rel}: a core page changed. A change to a core belief is the "
                            f"author's decision, recorded with --accept-core")
    for rel in baseline["core"]:
        if rel not in core_found:
            problems.append(f"{rel}: a core page was removed or renamed. The author records "
                            f"that with --accept-core")

    if args.report:
        for rel, (_, _, counts) in pages.items():
            if counts:
                mark = " (dedicated)" if rel in dedicated else ""
                listed = ", ".join(f"{k} {v}" for k, v in counts.most_common())
                print(f"  {rel}{mark}: {listed}")
        total = sum(corpus.values())
        print("  whole text, dedicated pages left out: "
              + ", ".join(f"{k} {percent(v / total)}" for k, v in corpus.most_common()))
        # Breadth and rotation, which the caps cannot see: how many traditions each part names,
        # and which tradition each core belief names first. Report only; nothing here can fail.
        by_part = defaultdict(Counter)
        for rel, (_, _, counts) in pages.items():
            if rel not in dedicated and rel.count("/") > 1:
                by_part[rel.split("/")[1]].update(counts)
        for part in sorted(by_part):
            named = +by_part[part]
            top, most = named.most_common(1)[0]
            print(f"  {part}: {len(named)} traditions named, {top} most at "
                  f"{percent(most / sum(named.values()))}")
        first = Counter()
        for rel, (text, _, counts) in pages.items():
            if "/core-beliefs/" not in rel or rel.endswith("README.md"):
                continue
            hits = [(m.start(), name) for name, pattern in traditions.items()
                    for m in [pattern.search(prose(text))] if m]
            if hits:
                first[min(hits)[1]] += 1
        if first:
            print("  named first on the core beliefs: "
                  + ", ".join(f"{k} {v}" for k, v in first.most_common()))

    if args.accept_core or args.waive_imbalance:
        if args.accept_core:
            baseline["core"] = core_found
        if args.waive_imbalance:
            baseline["pages"] = page_found
            baseline["sections"] = section_found
            baseline["corpus"] = corpus_found
        ordered = {
            "_about": "Written by scripts/check-doctrine.py. 'core' is the recorded text of the "
                      "core pages. 'pages', 'sections' and 'corpus' are imbalances between "
                      "traditions that exist today and are waiting for the author. Every entry "
                      "here is the author's decision; never add one to make the gate pass.",
            "core": dict(sorted(baseline["core"].items())),
            "pages": dict(sorted(baseline["pages"].items())),
            "sections": dict(sorted(baseline["sections"].items())),
            "corpus": baseline["corpus"],
        }
        (root / BASELINE).write_text(json.dumps(ordered, indent=2, ensure_ascii=False) + "\n",
                                     encoding="utf-8")
        print(f"check-doctrine: wrote {BASELINE}")
        return 0

    for line in problems:
        print(line)
    if problems:
        print(f"check-doctrine: {len(problems)} problem(s). See docs/doctrine-guardrails.md")
        return 1
    print(f"check-doctrine: passed ({len(pages)} pages, {len(core_found)} core pages locked, "
          f"{len(notes)} known imbalance(s) waiting for the author)")
    if args.report:
        for line in notes:
            print(f"  {line}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
