#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="2.3.1.1 - Ensure a single time synchronization daemon is in use"

PACKAGES='ntp chrony systemd-timesyncd'


audit() {
    for package in $PACKAGES; do
        if is_pkg_installed "$package"; then
            pass "$DESCRIPTION"
            return
        fi
    done
    crit "$DESCRIPTION"
    return 1
}


apply() {
    if apt_install "systemd-timesyncd"; then
        fixd "Installed package: systemd-timesyncd"
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