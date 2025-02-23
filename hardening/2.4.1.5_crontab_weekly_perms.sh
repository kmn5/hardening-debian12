#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.4.1.5 - Ensure permissions on /etc/cron.weekly are configured"

PACKAGE='cron'
FILE='/etc/cron.weekly'
USER='root'
GROUP='root'
PERMISSIONS='700'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
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