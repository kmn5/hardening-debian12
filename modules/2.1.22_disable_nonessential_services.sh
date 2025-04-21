#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="2.1.22 - Ensure only approved services are listening on a network interface"


audit() {
    if ss -plntuH | grep -qvE "(sshd|dhclient)"; then
        local sockets_multiline="$(ss -plntuH | awk '{print $5,$7}' | column -t | sort)"
        local sockets=()
        while IFS= read -r line; do
            sockets+=("$line")
        done <<< "$sockets_multiline"
        crit "$DESCRIPTION" "${sockets[@]}"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Remove or mask nonessential services."
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi