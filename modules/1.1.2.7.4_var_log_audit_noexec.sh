#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="1.1.2.7.4 - Ensure noexec option set on /var/log/audit partition"

PARTITION='/var/log/audit'
OPTION='noexec'


audit() {
    if ! is_a_partition "$PARTITION"; then
        return
    fi
    if ! has_mount_option "$PARTITION" "$OPTION"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if add_option_to_fstab "$PARTITION" "$OPTION"; then
        fixd "Mount option $OPTION set for $PARTITION in fstab"
    fi
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi