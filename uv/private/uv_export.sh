#!/usr/bin/env bash

set -euo pipefail

# inputs from Bazel
PYPROJECT_TOML="{{pyproject_toml}}"
REQUIREMENTS_TXT="{{requirements_txt}}"
COMPILE_COMMAND="{{compile_command}}"

updated_file=$(mktemp)
trap 'rm -f "$updated_file"' EXIT

{{uv}} export \
    {{args}} \
    --project="$(dirname "$PYPROJECT_TOML")" \
    --output-file="$updated_file" \
    "$@"

mv -f "$updated_file" "$REQUIREMENTS_TXT"
