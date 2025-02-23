#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.4.4 - Ensure the audit log directory mode is configured"

PACKAGE='auditd'
CONF_FILE='/etc/audit/auditd.conf'
PERMISSIONS='750'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    if ! has_file_less_permissions "$log_dir" "$PERMISSIONS"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    if ! has_file_less_permissions "$log_dir" "$PERMISSIONS"; then
        if chmod 0"$PERMISSIONS" "$log_dir";then
            fixd "Setting $log_dir permissions to $PERMISSIONS"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi