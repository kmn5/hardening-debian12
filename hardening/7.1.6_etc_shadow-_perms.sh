#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.1.6 - Ensure permissions on /etc/shadow- are configured"

FILE='/etc/shadow-'
USER='root'
GROUP='shadow'
GROUPSOK='shadow root'
PERMISSIONS='640'


audit() {
    if ! has_file_one_of_ownerships "$FILE" "$USER" "$GROUPSOK"; then
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
    if ! has_file_one_of_ownerships "$FILE" "$USER" "$GROUPSOK"; then
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