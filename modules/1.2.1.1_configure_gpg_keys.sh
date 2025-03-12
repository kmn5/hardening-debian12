#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.2.1.1 - Ensure GPG keys are configured"
PACKAGE="gpg"


audit() {
    if ! is_pkg_installed "$PACKAGE" && ! apt_install "$PACKAGE"; then
        info "$DESCRIPTION"
        warn "Gpg command not found. Skipping check"
        return
    fi
    local results=()
    readarray -t results <<< "$(gpg --show-keys /etc/apt/trusted.gpg.d/* 2>/dev/null | tr '\n' ' ' | sed 's/pub /\n/g' | perl -lne 'print "$1 $2" if /(\d\d\d\d-\d\d-\d\d).*uid\W*(.*) sub/')"
    info "$DESCRIPTION" "${results[@]}"
}


apply() {
    :
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi