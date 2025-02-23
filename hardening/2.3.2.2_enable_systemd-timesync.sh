#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.3.2.2 - Ensure systemd-timesyncd is enabled and running"

OTHER_PACKAGES='ntp chrony'
SERVICE_NAME='systemd-timesyncd.service'


audit() {
    for package in $OTHER_PACKAGES; do
        if is_pkg_installed "$package"; then
            return
        fi
    done
    if ! is_service_enabled "$SERVICE_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    if ! is_service_active "$SERVICE_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if systemctl unmask "$SERVICE_NAME" 2>/dev/null && systemctl --now enable "$SERVICE_NAME" 2>/dev/null; then
        fixd "Enabled $SERVICE_NAME daemon"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi