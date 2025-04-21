#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=4

DESCRIPTION="1.6.3 - Ensure remote login warning banner is configured properly"

FILE='/etc/issue.net'
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
    if write_to_file "$FILE" "Authorized users only. All activity may be monitored and reported."; then
        fixd "Replaced content of $FILE with legal status information"
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