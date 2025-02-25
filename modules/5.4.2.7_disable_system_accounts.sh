#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.2.7 - Ensure system accounts do not have a valid login shell"

PASSWD_FILE='/etc/passwd'
VALID_SHELLS="$(grep -E '^/' /etc/shells | grep -Ev '\bnologin\b' | paste -sd' ')"
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)


audit() {
    local results=()
    while read -r user uid shell; do
        if [[ "$uid" -lt "$UID_MIN" || "$uid" == "65534" ]]; then
            if list_contains "$VALID_SHELLS" "$shell"; then
                results+=("$user($shell)")
            fi
        fi
    done < <(awk -F: '($1 !~ /^(root|halt|sync|shutdown|nfsnobody)$/) {print $1" "$3" "$7}' "$PASSWD_FILE")
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "Login shell accounts: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    while read -r user uid shell; do
        if [[ "$uid" -lt "$UID_MIN" || "$uid" == "65534" ]]; then
            if list_contains "$VALID_SHELLS" "$shell"; then
                if usermod -s $(command -v nologin) "$user" 2>/dev/null; then
                    fixd "Shell for account $user set to $(command -v nologin)"
                fi
            fi
        fi
    done < <(awk -F: '($1 !~ /^(root|halt|sync|shutdown|nfsnobody)$/) {print $1" "$3" "$7}' "$PASSWD_FILE")
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi