#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.2.4 - Ensure root password is set"

FILE='/etc/shadow'
PATTERN='^root:[*\!]?:'


audit() {
    if does_pattern_exist_in_file "$FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Run the following command to set a password for the root user:"\
         " passwd root"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi