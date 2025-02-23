#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="4.1.2 - Ensure iptables-persistent is not installed with ufw"

PACKAGE='ufw'
PACKAGES='iptables-persistent'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for package in $PACKAGES; do
        if is_pkg_installed "$package"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for package in $PACKAGES; do
        if is_pkg_installed "$package"; then
            if apt_purge "$package"; then
                fixd "Purged $package package from the system"
            fi
            apt_autoremove
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi