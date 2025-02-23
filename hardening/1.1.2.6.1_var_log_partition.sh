#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.1.2.6.1 - Ensure separate partition exists for /var/log"

PARTITION='/var/log'


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
    warn "Specify during installation or create a new parition"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi