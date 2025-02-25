#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.4.1.1 - Ensure cron daemon is enabled and active"

PACKAGE='cron'
SERVICE_NAME='cron.service'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! is_service_enabled "$SERVICE_NAME" || ! is_service_active "$SERVICE_NAME"; then
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