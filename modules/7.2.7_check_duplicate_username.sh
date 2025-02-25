#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.7 - Ensure no duplicate user names exist"

PASSWD_FILE='/etc/passwd'


audit() {
    local results=()
    while read -r user; do
        results+=("$user")
    done < <(cut -d: -f1 "$PASSWD_FILE" | sort -n | uniq -d)
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "Duplicate users: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Establish unique user names for the users; file ownerships will automatically reflect the change as long as the users have unique UIDs"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi