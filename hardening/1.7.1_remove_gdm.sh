#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.8.1 - Ensure GNOME Display Manager (GDM) is removed"

PACKAGE_NAME='gdm3'


audit() {
    if is_pkg_installed "$PACKAGE_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if apt_purge $PACKAGE_NAME; then
        fixd "Purged $PACKAGE_NAME package from the system"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi