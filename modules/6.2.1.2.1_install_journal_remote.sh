#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.2.1 - Ensure systemd-journal-remote is installed"

PACKAGES='systemd-journal-remote'
OTHER_PACKAGES='rsyslog syslog-ng'


audit() {
    for package in $OTHER_PACKAGES; do
        if is_pkg_installed "$package"; then
            info "$DESCRIPTION -> Different logging service installed ($package)"
            return
        fi
    done
    for package in $PACKAGES; do
        if ! is_pkg_installed "$package"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    warn "Preferring rsyslog, so this step will be skipped"
    return
    if apt_install "$PACKAGES"; then
        fixd "Installed packages: $PACKAGES"
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