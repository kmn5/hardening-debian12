#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.1.9 - Ensure network file system services are not in use"

PACKAGES='nfs-kernel-server'


audit() {
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