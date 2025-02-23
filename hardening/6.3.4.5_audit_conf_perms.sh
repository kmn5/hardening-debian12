#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.4.5 - Ensure audit configuration files mode is configured"

PACKAGE='auditd'
CONF_FIND='/etc/audit/*.conf /etc/audit/*/*.conf /etc/audit/*.rules /etc/audit/*/*.rules'
PERMISSIONS='640'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $CONF_FIND; do
        [[ -f "$file" ]] || continue
        if ! has_file_less_permissions "$file" "$PERMISSIONS"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $CONF_FIND; do
        [[ -f "$file" ]] || continue
        if ! has_file_less_permissions "$file" "$PERMISSIONS"; then
            if chmod 0"$PERMISSIONS" "$file";then
                fixd "Permissions for $file set to $PERMISSIONS"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi