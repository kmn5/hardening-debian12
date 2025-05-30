#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="4.1.1 - Ensure ufw is installed"

OTHER_PACKAGES='firewalld nftables'
PACKAGE='ufw'


audit() {
    if is_pkg_installed "$PACKAGE"; then
        pass "$DESCRIPTION"
        return
    fi
    for package in $OTHER_PACKAGES; do
        if is_pkg_installed "$package" && ( is_service_active "$package.service" || is_service_enabled "$package.service" ); then
            info "$DESCRIPTION -> Different firewall installed ($package)"
            return
        fi
    done
    crit "$DESCRIPTION"
    return 1
}


apply() {
    if apt_install "$PACKAGE"; then
        fixd "Installed packages: $PACKAGE"
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