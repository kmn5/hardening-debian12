#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.3.1.1 - Ensure latest version of pam is installed"

PACKAGE='libpam-runtime'
VERSION='1.5.2-6'


audit() {
    if ! is_pkg_up_to_date "$PACKAGE" "$VERSION"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if DEBIAN_FRONTEND='noninteractive' apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade -y "$PACKAGE" 2>/dev/null; then
        fixd "Updated $PACKAGE to the latest version"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi
