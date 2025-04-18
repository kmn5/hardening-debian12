#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

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


if ! audit && $SCRIPT_APPLY; then
    apply
fi