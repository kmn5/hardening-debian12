#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.1.1 - Ensure journald service is enabled and active"

SERVICE_NAME='systemd-journald.service'


audit() {
    if ! is_service_static "$SERVICE_NAME"; then
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
    if systemctl unmask "$SERVICE_NAME" 2>/dev/null && systemctl start "$SERVICE_NAME" 2>/dev/null; then
        if is_service_static "$SERVICE_NAME" && is_service_active "$SERVICE_NAME"; then
            fixd "Enabled $SERVICE_NAME daemon"
        fi
    fi
    warn "By default the systemd-journald service does not have an [Install] section and thus"\
         "cannot be enabled / disabled. It is meant to be referenced as Requires or Wants by other"\
         "unit files. As such, if the status of systemd-journald is not static, investigate why."
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi