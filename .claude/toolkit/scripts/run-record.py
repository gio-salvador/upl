#!/usr/bin/env python3
"""Emit and summarise run records (Goal G58).

Optimisation without measurement is preference dressed as engineering. The efficiency observer
is required to cite evidence, and until now there was a format and nothing that produced one.

Two operations:

  append   validate a record and append it to the repository's declared record file
  summary  read the records back and report what they actually show

WHAT IS NOT RECORDED, AND WHY IT MATTERS. The shape of a run only: counts, rounds, outcomes. No
claims, no file contents, no client or engagement material. That is what makes a record safe to
read on any surface, quote in a pull request, or hand to somebody debugging a slow build.

THE THRESHOLD IS A REFUSAL, NOT A FILTER. A run below the profile's
`efficiency.observer_threshold_tool_calls` is not recorded at all: measuring a two-file edit
costs more than it saves, and a file full of trivial runs makes the real ones harder to see.
"""
import argparse, datetime, json, os, subprocess, sys

def root():
    r = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit("run-record: not inside a git repository")
    return r.stdout.strip()

def home():
    return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def yaml_load(path):
    try:
        import yaml
    except ImportError:
        sys.exit("run-record: pyyaml is required")
    if not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)

def profile_value(prof, *keys, default=None):
    node = prof or {}
    for k in keys:
        if not isinstance(node, dict) or k not in node:
            return default
        node = node[k]
    return node

def record_path(r, prof):
    rel = profile_value(prof, "efficiency", "record_path",
                        default=".claude/efficiency/run-records.yaml")
    # Must stay inside the repository: one project's measurements never land in another's.
    full = os.path.normpath(os.path.join(r, rel))
    if not full.startswith(os.path.realpath(r)) and not full.startswith(r):
        sys.exit("run-record: efficiency.record_path escapes the repository: %s" % rel)
    return full

def cmd_append(a, r, prof):
    threshold = profile_value(prof, "efficiency", "observer_threshold_tool_calls", default=40)
    if a.tool_calls is not None and a.tool_calls < threshold:
        print("run-record: %d tool calls is below the threshold of %d; not recorded "
              "(measuring a small run costs more than it saves)" % (a.tool_calls, threshold))
        return 0

    rec = {
        "run": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "task": a.task,
        "outcome": a.outcome,
    }
    if a.work_unit: rec["work_unit"] = a.work_unit
    if a.units is not None: rec["units"] = a.units
    if a.tool_calls is not None: rec["tool_calls"] = a.tool_calls
    if a.review_rounds:
        rec["review_rounds"] = [int(x) for x in a.review_rounds.split(",") if x.strip()]
    if a.rework is not None: rec["rework"] = a.rework
    if a.pivots is not None: rec["pivots"] = a.pivots
    if a.degraded: rec["degraded_checks"] = [d for d in a.degraded]
    if a.notes: rec["notes"] = a.notes

    # Validated like every other declaration, using the same validator.
    tmp = os.path.join(r, ".sct-run-record.tmp.json")
    with open(tmp, "w", encoding="utf-8") as fh:
        json.dump(rec, fh)
    rc = subprocess.run([sys.executable, os.path.join(home(), "scripts", "validate.py"),
                         "--schema", os.path.join(home(), "schemas", "run-record.schema.json"),
                         "--file", tmp]).returncode
    os.unlink(tmp)
    if rc != 0:
        return 1

    path = record_path(r, prof)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    import yaml
    with open(path, "a", encoding="utf-8") as fh:
        if os.path.getsize(path) == 0 if os.path.exists(path) else True:
            fh.write("# Run records (Goal G58). Append-only: never edit or reorder, the point is\n"
                     "# the trend. Shape of a run only, never its content.\n")
        fh.write(yaml.safe_dump([rec], sort_keys=False, default_flow_style=False))
    print("run-record: appended to %s" % os.path.relpath(path, r))
    # G57: observation is STANDING above the threshold, not something to remember to ask for.
    # The record is the one place a run's size is already known, so the signal is emitted here
    # rather than left to the orchestrator's judgement (TK-077).
    if a.tool_calls is not None and a.tool_calls >= threshold:
        print("run-record: %d tool calls is at or above the observer threshold of %d.\n"
              "  Engage sc-efficiency-optimizer on this run. It is advisory and non-blocking,\n"
              "  and its proposals are held to `check-proposal.sh`: efficiency never buys\n"
              "  itself with quality." % (a.tool_calls, threshold))
    return 0

def cmd_summary(a, r, prof):
    path = record_path(r, prof)
    data = yaml_load(path)
    if not data:
        print("run-record: no records yet at %s" % os.path.relpath(path, r))
        return 0
    cap = profile_value(prof, "efficiency", "review_loop_cap", default=3)
    n = len(data)
    rounds = [x for rec in data for x in (rec.get("review_rounds") or [])]
    at_cap = sum(1 for x in rounds if x >= cap)
    rework = sum(rec.get("rework", 0) for rec in data)
    pivots = sum(rec.get("pivots", 0) for rec in data)
    degraded = [d for rec in data for d in (rec.get("degraded_checks") or [])]
    outcomes = {}
    for rec in data:
        outcomes[rec.get("outcome", "?")] = outcomes.get(rec.get("outcome", "?"), 0) + 1

    print("run records: %d" % n)
    if rounds:
        print("  review rounds: %d recorded, %d at the cap of %d (%.0f%%)"
              % (len(rounds), at_cap, cap, 100.0 * at_cap / len(rounds)))
        if at_cap and at_cap / len(rounds) > 0.25:
            print("    more than a quarter of units never converged: that is a contract problem,")
            print("    not a writing problem. Look at what the units were asked to do.")
    print("  rework: %d unit(s) reopened after being called done" % rework)
    if rework > n:
        print("    more reopenings than runs: something is being declared done too early.")
    print("  pivots: %d" % pivots)
    if pivots == 0 and rework > 0:
        print("    zero pivots with rework present usually means an approach was persisted with")
        print("    when it should have been changed (execution-doctrine section 2).")
    if degraded:
        print("  degraded checks across all runs: %d" % len(degraded))
        for d in sorted(set(degraded)):
            print("    - %s" % d)
        print("    a run that passed with gates unable to execute passed less than it appears to.")
    print("  outcomes: %s" % ", ".join("%s=%d" % kv for kv in sorted(outcomes.items())))
    return 0

def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    ap_a = sub.add_parser("append", help="validate and append a record")
    ap_a.add_argument("--task", required=True)
    ap_a.add_argument("--outcome", required=True, choices=["complete", "escalated", "abandoned"])
    ap_a.add_argument("--work-unit", dest="work_unit")
    ap_a.add_argument("--units", type=int)
    ap_a.add_argument("--tool-calls", dest="tool_calls", type=int)
    ap_a.add_argument("--review-rounds", dest="review_rounds",
                      help="comma-separated, one per unit")
    ap_a.add_argument("--rework", type=int)
    ap_a.add_argument("--pivots", type=int)
    ap_a.add_argument("--degraded", action="append", default=[],
                      help="a gate that could not run, and why; repeatable")
    ap_a.add_argument("--notes")
    sub.add_parser("summary", help="report what the records show")
    a = ap.parse_args()

    r = root()
    prof = yaml_load(os.path.join(r, ".claude", "profile.yaml"))
    return cmd_append(a, r, prof) if a.cmd == "append" else cmd_summary(a, r, prof)

if __name__ == "__main__":
    sys.exit(main())
