#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.2.5 - Ensure re-authentication for privilege escalation is not disabled globally"

PACKAGE='sudo'
CONF_FIND='/etc/sudoers /etc/sudoers.d/*'
SUDO_PATTERN='^[^#].*\!authenticate'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$SUDO_PATTERN"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $CONF_FIND; do
        if comment_out_sudo_pattern "$file" "$SUDO_PATTERN"; then
            fixd "Removed any lines with occurences of !authenticate in $file"
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi