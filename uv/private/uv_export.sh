#!/usr/bin/env bash

set -euo pipefail

# inputs from Bazel
PYPROJECT_TOML="{{pyproject_toml}}"
REQUIREMENTS_TXT="{{requirements_txt}}"
COMPILE_COMMAND="{{compile_command}}"
UV_LOCK="{{uv_lock}}"

# If uv.lock exists in the project directory, update it first
PROJECT_DIR="$(dirname "$PYPROJECT_TOML")"
LOCK_FILE="$PROJECT_DIR/uv.lock"

# If UV_LOCK is provided, ensure it is the same as LOCK_FILE
if [ -n "$UV_LOCK" ] && ! [ "$UV_LOCK" -ef "$LOCK_FILE" ]; then
    echo "Error: uv_lock ($UV_LOCK) is not the same file as expected ($LOCK_FILE). Please ensure uv_lock is in the same directory as pyproject.toml."
    exit 1
fi

if [ -f "$LOCK_FILE" ]; then
    # Check if lockfile is up to date (non-empty and valid for current pyproject.toml)
    if [ ! -s "$LOCK_FILE" ] || ! {{uv}} sync --project "$PROJECT_DIR" --locked --dry-run {{python_arg}} {{uv_lock_args}} >/dev/null 2>&1; then
        # If lockfile exists but is empty, remove it so uv lock starts fresh
        if [ -f "$LOCK_FILE" ] && [ ! -s "$LOCK_FILE" ]; then
            rm -f "$LOCK_FILE"
        fi

        {{uv}} lock --project "$PROJECT_DIR" {{python_arg}} {{uv_lock_args}}

        # If BUILD_WORKSPACE_DIRECTORY is set, copy generated uv.lock back to source
        if [ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]; then
            REL_DIR="$(dirname "$PYPROJECT_TOML")"
            SOURCE_LOCK="$BUILD_WORKSPACE_DIRECTORY/$REL_DIR/uv.lock"

            if [ -f "$SOURCE_LOCK" ] || [ -f "$LOCK_FILE" ]; then
                #  If the target LOCK_FILE is a different file, overwrite it with the generated uv.lock
                if ! [ "$LOCK_FILE" -ef "$SOURCE_LOCK" ]; then
                    cp "$LOCK_FILE" "$SOURCE_LOCK"
                fi
            fi
        fi
    fi
fi

{{uv}} export \
    {{args}} \
    --project=$PROJECT_DIR \
    --output-file="$REQUIREMENTS_TXT" \
    "$@"
