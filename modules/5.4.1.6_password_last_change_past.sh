#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi