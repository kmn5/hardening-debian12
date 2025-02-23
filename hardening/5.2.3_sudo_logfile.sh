#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.2.3 - Ensure sudo log file exists"

PACKAGE='sudo'
CONF_FILE='/etc/sudoers'
CONF_FIND='/etc/sudoers /etc/sudoers.d/*'
SUDO_PATTERN='^\s*defaults\s+([^#]+,\s*)?logfile\s*=[^#]'
SUDO_PARAM='logfile="/var/log/sudo.log"'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$SUDO_PATTERN"; then
            pass "$DESCRIPTION"
            return
        fi
    done
    crit "$DESCRIPTION"
    return 1
}


apply() {
    if set_sudo_default_param "$CONF_FILE" "$SUDO_PARAM"; then
        fixd "Parameter $SUDO_PARAM set in $CONF_FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi