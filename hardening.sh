#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

# Initialize variables
SCRIPT_ROOT_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")"
SCRIPT_MODULES_DIR="$SCRIPT_ROOT_DIR/modules"
export SCRIPT_LIB_DIR="$SCRIPT_ROOT_DIR/lib"


# Parse every script and execute them
for SCRIPT_MODULE in $(find "${SCRIPT_MODULES_DIR}"/ -name "*.sh" | sort -V); do
    /bin/bash "$SCRIPT_MODULE" "$@"
done