#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.3.4.4 - Ensure ntp is enabled and running (deprecated)"

PACKAGE='ntp'
SERVICE_NAME='ntp.service'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! is_service_enabled "$SERVICE_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    :
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi