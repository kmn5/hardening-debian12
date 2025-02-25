#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.2.1 - Ensure root is the only UID 0 account"

PASSWD_FILE='/etc/passwd'


audit() {
    if [[ $(id -u root 2>/dev/null) != "0" ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    local results=()
    while read -r user uid; do
        if [[ "$uid" == "0" && "$user" != "root" ]]; then
            results+=("$user")
        fi
    done < <(awk -F: '{print $1" "$3}' "$PASSWD_FILE")
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "UID 0 users: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if [[ $(id -u root 2>/dev/null) != "0" ]]; then
        if usermod -u 0 root 2>/dev/null; then
            fixd "UID for user root set to 0"
        fi
    fi
    warn "Modify any users other than root with UID 0 and assign them a new UID"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi