#!/usr/bin/env bash

set -euo pipefail

# inputs from Bazel
PYPROJECT_TOML="{{pyproject_toml}}"
REQUIREMENTS_TXT="{{requirements_txt}}"
COMPILE_COMMAND="{{compile_command}}"
UV_LOCK="{{uv_lock}}"

# make a writable copy of incoming requirements
updated_file=$(mktemp)
trap 'rm -f "$updated_file"' EXIT
cp "$REQUIREMENTS_TXT" "$updated_file"

# Check if uv.lock exists in the project directory
PROJECT_DIR="$(dirname "$PYPROJECT_TOML")"
LOCK_FILE="$PROJECT_DIR/uv.lock"

# If UV_LOCK is provided, ensure it is the same as LOCK_FILE
if ! [ "$UV_LOCK" -ef "$LOCK_FILE" ]; then
    echo "Error: uv_lock ($UV_LOCK) is not the same file as expected ($LOCK_FILE). Please ensure uv_lock is in the same directory as pyproject.toml."
    exit 1
fi

{{uv}} export \
    --quiet \
    --no-cache \
    --locked \
    {{args}} \
    --project="$PROJECT_DIR" \
    --output-file="$updated_file" \
    "$@"

# check files match
DIFF="$(diff "$REQUIREMENTS_TXT" "$updated_file" || true)"
if [ "$DIFF" != "" ]
then
  echo >&2 "FAIL: $REQUIREMENTS_TXT is out-of-date. Run '$COMPILE_COMMAND' to update."
  echo >&2 "$DIFF"
  exit 1
fi
