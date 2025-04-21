#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="6.3.3.21 - Ensure the running and on disk configuration is the same"

PACKAGE='auditd'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! augenrules --check | grep -q "No change"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local reboot_required=1
    if [[ $(auditctl -s | grep "enabled") =~ "2" ]]; then
        local reboot_required=0
    fi
    if ! augenrules --load 2>/dev/null 1>&2; then
        warn "Failed loading audit rules, please check errors below and manually load them with 'augenrules --load'"
        augenrules --load 2>&1 1>/dev/null | awk '{print " ",$0}'
        return 1
    fi
    if [[ "$reboot_required" = 0 ]]; then
        info_sub "Immutable mode detected. Please check if audit rules loaded successfully after reboot with 'auditctl -l'"
    else
        fixd "Successfully loaded audit rules"
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