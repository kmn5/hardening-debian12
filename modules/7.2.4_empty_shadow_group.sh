#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.4 - Ensure shadow group is empty"

GROUP='shadow'
PASSWD_FILE='/etc/passwd'


audit() {
    local group_users=$(getent group "$GROUP" | cut -d: -f4 | tr ',' ' ')
    if [[ -n "$group_users" ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    local group_id=$(getent group "$GROUP" | cut -d: -f3)
    if cut -d: -f4 "$PASSWD_FILE" | grep -x "$group_id" 2>/dev/null 1>&2; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local group_users=$(getent group "$GROUP" | cut -d: -f4 | tr ',' ' ')
    for user in $group_users; do
        if gpasswd -d "$user" "$GROUP" 2>/dev/null 1>&2; then
            fixd "Removed user $user from group $GROUP"
        fi
    done
    local group_id=$(getent group "$GROUP" | cut -d: -f3)
    while IFS=: read -r user group; do
        if [[ "$group" == "$group_id" ]]; then
            if usermod -g nogroup "$user" 2>/dev/null; then
                fixd "Primary group for user $user set to nogroup"
            fi
        fi
    done < <(cut -d: -f1,4 "$PASSWD_FILE")
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi