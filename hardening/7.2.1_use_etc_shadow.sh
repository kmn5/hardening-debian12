#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.1 - Ensure accounts in /etc/passwd use shadowed passwords"

FILE='/etc/passwd'
PATTERN='^[^:]+:[^x][^:]'


audit() {
    if does_pattern_exist_in_file "$FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if pwconv  2>/dev/null; then
        fixd "Shadowed passwords in $FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi