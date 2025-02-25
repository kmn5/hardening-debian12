#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.1.6 - Ensure all users last password change date is in the past"

SHADOW_FILE='/etc/shadow'


audit() {
    local days_since_epoch=$(($(date +%s) / 86400))
    local results=()
    while read -r user lastchange; do
        if [[ "$lastchange" -gt "$days_since_epoch" ]]; then
            results+=("$user")
        fi
    done < <(awk -F: '$2~/^\$.+\$/{print $1" "$3}' "$SHADOW_FILE")
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "Future users: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Investigate any users with a password change date in the future and correct them."\
         "Locking the account, expiring the password, or resetting the password manually may be"\
         "appropriate."
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi