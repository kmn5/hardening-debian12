#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.4.8 - Ensure audit tools mode is configured"

PACKAGE='auditd'
AUDIT_TOOLS='/sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules'
PERMISSIONS='755'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $AUDIT_TOOLS; do
        [[ -f "$file" ]] || continue
        if ! has_file_less_permissions "$file" "$PERMISSIONS"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $AUDIT_TOOLS; do
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