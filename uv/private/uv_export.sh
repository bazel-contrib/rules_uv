#!/usr/bin/env bash

set -euo pipefail

# inputs from Bazel
PYPROJECT_TOML="{{pyproject_toml}}"
REQUIREMENTS_TXT="{{requirements_txt}}"
COMPILE_COMMAND="{{compile_command}}"

{{uv}} export \
    {{args}} \
    --project="$(dirname "$PYPROJECT_TOML")" \
    --output-file="$REQUIREMENTS_TXT" \
    "$@"
