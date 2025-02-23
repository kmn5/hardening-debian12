#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.2.4 - Ensure users must provide password for privilege escalation"

PACKAGE='sudo'
CONF_FILE='/etc/sudoers'
CONF_FIND='/etc/sudoers /etc/sudoers.d/*'
SUDO_PATTERN='^[^#]*NOPASSWD'


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
    if comment_out_sudo_pattern "$CONF_FILE" "$SUDO_PATTERN"; then
        fixd "Removed any lines with occurences of NOPASSWD in $file"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi