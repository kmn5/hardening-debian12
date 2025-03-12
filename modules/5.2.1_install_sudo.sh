#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.2.1 - Ensure sudo is installed"

PACKAGES='sudo'
GROUP='sudo'
USER_ID='1000'


audit() {
    for package in $PACKAGES; do
        if ! is_pkg_installed "$package"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    if apt_install "$PACKAGES"; then
        fixd "Installed packages: $PACKAGES"
        local username=$(id -nu "$USER_ID" 2>/dev/null)
        if [[ -n "$username" ]] && usermod -aG "$GROUP" "$username" 2>/dev/null; then
            info_sub "Added user $username to group $GROUP"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi