#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

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
    if local upgrade_result=$(DEBIAN_FRONTEND='noninteractive' APT_LISTBUGS_FRONTEND='none' apt-get -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade -y 2>/dev/null | grep "upgraded,"); then
        fixd "$upgrade_result"
    fi
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi