#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

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
            info "$DESCRIPTION"
            warn "Different firewall detected ($package). Skipping installation"
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


if ! audit && $SCRIPT_APPLY; then
    apply
fi