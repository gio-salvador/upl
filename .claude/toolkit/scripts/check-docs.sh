#!/usr/bin/env bash
# The documentation gate, invoked with this repository's own paths (Goal G12).
#
# A thin wrapper on purpose: the checker is generic and shared, and every repository's paths
# differ. Putting the invocation in one script means the test suite, CI and a person all run
# exactly the same check, which is the only way a gate's result means anything.
set -uo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
root="$(sct_root)" || exit 2
home="$(sct_home)"
man="$root/.claude/docs-sync.yaml"

skills="$(sct_yaml_get "$man" skills_dir)"; skills="${skills:-.claude/skills}"
agents="$(sct_yaml_get "$man" agents_dir)"; agents="${agents:-.claude/agents}"
docs="$(sct_yaml_get "$man" docs_root)";    docs="${docs:-docs}"

args=(--root "$root" --skills-dir "$skills" --agents-dir "$agents" --docs-root "$docs")
# Exclusions are a list; read them without a YAML parser (the shapes stay simple by design).
while IFS= read -r g; do
  g="$(printf '%s' "$g" | sed -E 's/^[[:space:]]*-[[:space:]]*//; s/[[:space:]]*$//')"
  [ -n "$g" ] && args+=(--exclude "$g")
done < <(awk '/^exclude:/{f=1;next} f&&/^[[:space:]]*-/{print} f&&/^[^[:space:]-]/{exit}' "$man" 2>/dev/null)

exec python3 "$home/config/docs/check-docs.py" "${args[@]}" "$@"
