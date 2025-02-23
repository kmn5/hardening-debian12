#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.1.13 - Ensure rsync services are not in use"

PACKAGE='rsync'
SERVICE_NAME='rsync'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        pass "$DESCRIPTION"
        return
    fi
    if is_service_enabled "$SERVICE_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    if is_service_active "$SERVICE_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if systemctl stop "$SERVICE_NAME" 2>/dev/null && systemctl mask "$SERVICE_NAME" 2>/dev/null; then
        fixd "Masked $SERVICE_NAME service"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi