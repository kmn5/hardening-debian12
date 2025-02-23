#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.1.10 - Ensure permissions on /etc/security/opasswd are configured"

FILES_FIND='/etc/security/opasswd /etc/security/opasswd.old'
USER='root'
GROUP='root'
PERMISSIONS='600'


audit() {
    for file in $FILES_FIND; do
        if ! does_file_exist "$file"; then
            continue
        fi
        if ! has_file_correct_ownership "$file" "$USER" "$GROUP"; then
            crit "$DESCRIPTION"
            return 1
        fi
        if ! has_file_less_permissions "$file" "$PERMISSIONS"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $FILES_FIND; do
        if ! does_file_exist "$file"; then
            continue
        fi
        if ! has_file_correct_ownership "$file" "$USER" "$GROUP"; then
            if chown "$USER":"$GROUP" "$file"; then
                fixd "Ownership for $file set to $USER:$GROUP"
            fi
        fi
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