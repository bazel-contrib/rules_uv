#!/usr/bin/env bash

set -euo pipefail

# inputs from Bazel
PYPROJECT_TOML="{{pyproject_toml}}"
REQUIREMENTS_TXT="{{requirements_txt}}"
COMPILE_COMMAND="{{compile_command}}"

PYPROJECT_TOML="$(realpath "$PYPROJECT_TOML")"
REQUIREMENTS_TXT="$(realpath "$REQUIREMENTS_TXT")"

updated_file=$(mktemp -p "$(dirname "$REQUIREMENTS_TXT")" ".$(basename "$REQUIREMENTS_TXT").tmp.XXXXXX")
trap 'rm -f "$updated_file"' EXIT

{{uv}} export \
    {{args}} \
    --project="$(dirname "$PYPROJECT_TOML")" \
    "$@" \
    > "$REQUIREMENTS_TXT"

# cp -f "$updated_file" "$REQUIREMENTS_TXT"
