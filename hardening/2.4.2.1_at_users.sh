#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.4.2.1 - Ensure at is restricted to authorized users"

PACKAGE='at'
DENY_FILE='/etc/at.deny'
ALLOW_FILE='/etc/at.allow'
USER='root'
GROUP='daemon'
PERMISSIONS='640'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if [[ ! -f "$ALLOW_FILE" ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    if ! has_file_correct_ownership "$ALLOW_FILE" "$USER" "$GROUP"; then
        crit "$DESCRIPTION"
        return 1
    fi
    if ! has_file_correct_permissions "$ALLOW_FILE" "$PERMISSIONS"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if [[ -f "$DENY_FILE" ]]; then
        if delete_file "$DENY_FILE"; then
            fixd "Removed $DENY_FILE from the system"
        fi
    fi
    if [[ ! -f "$ALLOW_FILE" ]]; then
        if touch "$ALLOW_FILE"; then
            fixd "Created $ALLOW_FILE from the system"
        fi
    fi
    if ! has_file_correct_ownership "$ALLOW_FILE" "$USER" "$GROUP"; then
        if chown "$USER":"$GROUP" "$ALLOW_FILE"; then
            fixd "Ownership for $ALLOW_FILE set to $USER:$GROUP"
        fi
    fi
    if ! has_file_less_permissions "$ALLOW_FILE" "$PERMISSIONS"; then
        if chmod 0"$PERMISSIONS" "$ALLOW_FILE";then
            fixd "Permissions for $ALLOW_FILE set to $PERMISSIONS"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi