#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.2.4 - Ensure systemd-journal-remote service is not in use"

PACKAGE='systemd-journal-remote'
SERVICE_NAMES='systemd-journal-remote.service systemd-journal-remote.socket'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for service in $SERVICE_NAMES; do
        if is_service_enabled "$service"; then
            crit "$DESCRIPTION"
            return 1
        fi
        if is_service_active "$service"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    if systemctl stop $SERVICE_NAMES 2>/dev/null && systemctl mask $SERVICE_NAMES 2>/dev/null; then
        fixd "Disabled $SERVICE_NAMES daemons"
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