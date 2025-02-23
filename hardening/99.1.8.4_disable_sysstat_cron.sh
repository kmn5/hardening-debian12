#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="99.1.8.4 - Ensure additional sysstat cron job is disabled"

PACKAGE='sysstat'
FILE='/etc/cron.d/sysstat'
PATTERN='^[^#[:space:]].*'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if does_pattern_exist_in_file "$FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if comment_out_pattern_in_file "$FILE" "$PATTERN"; then
        fixd "Disabled sysstat cron file $FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi