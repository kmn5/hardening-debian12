#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=0

DESCRIPTION="0.1.1 - Ensure script is executed on supported environment"

TARGET_DISTRIBUTION='debian'
TARGET_VERSION_ID='12'


audit() {
    if [[ "$(get_distribution)" != "$TARGET_DISTRIBUTION" || "$(get_version_id)" != "$TARGET_VERSION_ID" ]]; then
        crit "$DESCRIPTION" "Running OS: $(get_distribution) $(get_version_id)" "Target OS: $TARGET_DISTRIBUTION $TARGET_VERSION_ID"
        exit 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    :
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi