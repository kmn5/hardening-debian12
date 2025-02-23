#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.1.2.2.2 - Ensure nodev option set on /dev/shm partition"

PARTITION='/dev/shm'
OPTION='nodev'


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


if ! audit && $SCRIPT_APPLY; then
    apply
fi