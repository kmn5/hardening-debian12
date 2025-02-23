#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.1.4 - Ensure permissions on /etc/group- are configured"

FILE='/etc/group-'
USER='root'
GROUP='root'
PERMISSIONS='644'


audit() {
    if ! has_file_correct_ownership "$FILE" "$USER" "$GROUP"; then
        crit "$DESCRIPTION"
        return 1
    fi
    if ! has_file_less_permissions "$FILE" "$PERMISSIONS"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if ! has_file_correct_ownership "$FILE" "$USER" "$GROUP"; then
        if chown "$USER":"$GROUP" "$FILE"; then
            fixd "Ownership for $FILE set to $USER:$GROUP"
        fi
    fi
    if ! has_file_less_permissions "$FILE" "$PERMISSIONS"; then
        if chmod 0"$PERMISSIONS" "$FILE";then
            fixd "Permissions for $FILE set to $PERMISSIONS"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi