#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.4.1 - Ensure bootloader password is set"

FILE='/boot/grub/grub.cfg'
USER_PATTERN='^set superusers'
PWD_PATTERN='^password_pbkdf2'


audit() {
    if ! does_pattern_exist_in_file "$FILE" "$USER_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    if ! does_pattern_exist_in_file "$FILE" "$PWD_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Configure a password for grub if possible"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi