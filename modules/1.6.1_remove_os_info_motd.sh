#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=4

DESCRIPTION="1.6.1 - Ensure message of the day is configured properly"

FILE='/etc/motd'
PATTERN="(\\\v|\\\r|\\\m|\\\s)"


audit() {
    if does_pattern_exist_in_file_nocase "$FILE" "$PATTERN" || \
       does_pattern_exist_in_file_nocase "$FILE" "$(get_distribution)"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if delete_file "$FILE"; then
        fixd "Removed $FILE from the system"
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