#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.1.2.2.1 - Ensure /dev/shm is a separate partition"

PARTITION='/dev/shm'


audit() {
    if ! is_a_partition "$PARTITION"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
    if ! is_mounted "$PARTITION"; then
        warn "$PARTITION is not mounted"
    fi
}


apply() {
    if add_end_of_file "/etc/fstab" "tmpfs           /dev/shm        tmpfs       defaults,rw,noexec,nodev,nosuid,relatime 0    0"; then
        fixd "Added mount point for $PARTITION"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi