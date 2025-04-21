#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="4.1.7 - Ensure ufw default deny firewall policy"

PACKAGE='ufw'
UFW_ROUTES='incoming outgoing routed'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local ufw_status=$(ufw status verbose)
    if ! echo "$ufw_status" | grep -q "Status: active"; then
        return
    fi
    for route in $UFW_ROUTES; do
        if ! echo "$ufw_status" | grep -Eq "^Default:.*(deny|reject|disabled) \($route\)"; then
            crit "$DESCRIPTION" "$(echo "$ufw_status" | grep -E "^Default:" | cut -c 10-)"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    warn "Run the following commands to implement a default deny policy:"\
         " ufw default deny incoming"\
         " ufw default deny outgoing"\
         " ufw default deny routed"
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi