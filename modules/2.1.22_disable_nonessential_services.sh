#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

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


if ! audit && $SCRIPT_APPLY; then
    apply
fi