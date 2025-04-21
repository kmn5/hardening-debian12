#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.2.2 - Ensure sudo commands use pty"

PACKAGE='sudo'
CONF_FILE='/etc/sudoers.d/50_hardening'
CONF_FIND='/etc/sudoers /etc/sudoers.d/*'
SUDO_PATTERN='^\s*defaults\s+([^#]+,\s*)?use_pty'
SUDO_PARAM='use_pty'


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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi