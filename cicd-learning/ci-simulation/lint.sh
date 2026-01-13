#!/usr/bin/env bash
set -euo pipefail

echo "Lint started..."

# 1. Ensure scripts are executable
chmod +x ./*.sh

# 2. If shellcheck exists, run it (best)
if command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck found. Running..."
  shellcheck ./*.sh
else
  echo "shellcheck not found. Skipping shellcheck."
  echo "NOTE: In CI we will install it before running lint."
fi

echo "Lint completed OK."

