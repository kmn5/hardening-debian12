#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.2.2.1 - Ensure updates, patches, and additional security software are installed"


audit() {
    info "Checking if apt needs an update"
    apt_update_if_needed
    if ! apt_check_upgrades; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    info "Applying upgrades..."
    if local upgrade_result=$(DEBIAN_FRONTEND='noninteractive' apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade -y 2>/dev/null | grep "upgraded"); then
        fixd "$upgrade_result"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi