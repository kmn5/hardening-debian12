#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

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


if ! audit && $SCRIPT_APPLY; then
    apply
fi