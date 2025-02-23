#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.1.1 - Ensure permissions on /etc/ssh/sshd_config are configured"

PACKAGE='openssh-server'
CONF_FIND='/etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf'
USER='root'
GROUP='root'
PERMISSIONS='600'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $CONF_FIND; do
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
    for file in $CONF_FIND; do
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