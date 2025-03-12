#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.1.1 - Ensure AIDE is installed"

PACKAGES='aide aide-common'
DB_FILE='/var/lib/aide/aide.db'


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
    if ! does_file_exist "$DB_FILE"; then
        info_sub "Initializing aide (this could take a while)"
        if aideinit -f -y 2>/dev/null 1>&2; then
            fixd "Initialized aide package"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi