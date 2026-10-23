#!/usr/bin/env bash
# Build or refresh the project virtualenv the gate prefers.
#
# tests/run.sh puts .venv/bin first on PATH when it exists, so the schema checks run on the
# pinned pyyaml instead of whatever the machine's python3 happens to carry. This is the one step
# that reaches the network, and it is a setup step, not a gate: run it once, and again when
# requirements.txt changes. Idempotent.
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/common.sh"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"   # the checkout this script ships in, not the cwd
py="${PYTHON:-python3}"
command -v "$py" >/dev/null 2>&1 || { sct_block "no $py to build the virtualenv from"; exit 2; }
[ -x "$root/.venv/bin/python3" ] || "$py" -m venv "$root/.venv"
"$root/.venv/bin/python3" -m pip install --quiet --disable-pip-version-check -r "$root/requirements.txt"
"$root/.venv/bin/python3" -c 'import yaml; print("setup-venv: .venv ready, pyyaml", yaml.__version__)'
