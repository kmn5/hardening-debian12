#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.3.1 - Ensure nologin is not listed in /etc/shells"

FILE='/etc/shells'
PATTERN='^[^#]*/nologin'


audit() {
    if does_pattern_exist_in_file "$FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if comment_out_pattern_in_file "$FILE" "$PATTERN"; then
        fixd "Removed /nologin shells from $FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi