#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.1.1.4 - Ensure journald ForwardToSyslog is disabled"

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


if ! audit && $SCRIPT_APPLY; then
    apply
fi