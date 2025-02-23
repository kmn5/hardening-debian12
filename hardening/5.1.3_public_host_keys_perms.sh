#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.1.3 - Ensure permissions on SSH public host key files are configured"

PACKAGE='openssh-server'
KEY_FIND='/etc/ssh/ssh_host_*_key.pub'
USER='root'
GROUP='root'
PERMISSIONS='644'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $KEY_FIND; do
        [[ -f "$file" ]] || continue
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
    for file in $KEY_FIND; do
        [[ -f "$file" ]] || continue
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