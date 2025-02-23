#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="99.9.2 - Ensure ufw IPT_SYSCTL is disabled"

PACKAGE='ufw'
FILE='/etc/default/ufw'
PATTERN='^[^#]*IPT_SYSCTL='


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
        fixd "Removed IPT_SYSCTL overrides from $FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi