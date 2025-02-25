#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.2.1.1 - Ensure GPG keys are configured"
PACKAGE="gpg"


audit() {
    info "$DESCRIPTION"
    if ! is_pkg_installed "$PACKAGE" && ! apt_install "$PACKAGE"; then
        return
    fi
    gpg --show-keys /etc/apt/trusted.gpg.d/* 2>/dev/null | tr '\n' ' ' | sed 's/pub /\n/g' | perl -lne 'print "  $1 $2" if /(\d\d\d\d-\d\d-\d\d).*uid\W*(.*) sub/'
}


apply() {
    :
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi