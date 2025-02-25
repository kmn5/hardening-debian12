#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.3.1.3 - Ensure libpam-pwquality is installed"

PACKAGES='libpam-pwquality'


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
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi
