#!/usr/bin/env bash

set -euo pipefail

# inputs from Bazel
REQUIREMENTS_IN="{{requirements_in}}"
REQUIREMENTS_TXT="{{requirements_txt}}"
CONSTRAINTS_TXT="{{constraints_txt}}"

{{uv}} pip compile \
    {{args}} \
    ${CONSTRAINTS_TXT:+--constraint="$CONSTRAINTS_TXT"} \
    --output-file="$REQUIREMENTS_TXT" \
    "$REQUIREMENTS_IN" \
    "$@"
