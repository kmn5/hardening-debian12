#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.4.1 - Ensure audit log files mode is configured"

PACKAGE='auditd'
CONF_FILE='/etc/audit/auditd.conf'
PERMISSIONS='640'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    for file in $log_dir/*; do
        [[ -f "$file" ]] || continue
        if ! has_file_less_permissions "$file" "$PERMISSIONS"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    for file in $log_dir/*; do
        [[ -f "$file" ]] || continue
        if ! has_file_less_permissions "$file" "$PERMISSIONS"; then
            if chmod 0"$PERMISSIONS" "$file";then
                fixd "Permissions for $FILE set to $PERMISSIONS"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi