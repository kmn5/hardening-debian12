#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.6.2 - Ensure local login warning banner is configured properly"

FILE='/etc/issue'
get_distribution
PATTERN="(\\\v|\\\r|\\\m|\\\s|$DISTRIBUTION)"


audit() {
    if does_file_exist "$FILE" && does_pattern_exist_in_file_nocase "$FILE" "$PATTERN"; then
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


if ! audit && $SCRIPT_APPLY; then
    apply
fi