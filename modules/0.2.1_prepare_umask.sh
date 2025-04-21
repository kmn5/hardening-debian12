#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=0

DESCRIPTION="0.2.1 - Ensure script is running with proper umask"

PATTERN='^[0-7]?[0-7]([01][0-7]|[0-7][0-6])$'
UMASK='0027'


audit() {
    if umask | grep -Eq "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if umask "$UMASK" 2>/dev/null 1>&2; then
        fixd "UMASK set to $UMASK for script runtime"
    fi
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi