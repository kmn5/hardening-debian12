#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="6.1.2 - Ensure filesystem integrity is regularly checked"

SERVICE_NAME='dailyaidecheck.service'
TIMER_NAME='dailyaidecheck.timer'

audit() {
    if ! ( is_service_enabled "$SERVICE_NAME" || is_service_static "$SERVICE_NAME" ); then
        crit "$DESCRIPTION"
        return 1
    fi
    if ! is_service_enabled "$TIMER_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if systemctl unmask "$TIMER_NAME" "$SERVICE_NAME" 2>/dev/null && systemctl --now enable "$TIMER_NAME" 2>/dev/null; then
        fixd "Enabled $TIMER_NAME daemon"
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