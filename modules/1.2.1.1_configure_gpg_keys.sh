#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi