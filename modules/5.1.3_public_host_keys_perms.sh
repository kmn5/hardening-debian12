#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi