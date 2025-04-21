#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.4.2.8 - Ensure accounts without a valid login shell are locked"

PASSWD_FILE='/etc/passwd'
VALID_SHELLS="$(grep -E '^/' /etc/shells | grep -Ev '\bnologin\b' | paste -sd' ')"


audit() {
    local results=()
    while read -r user shell; do
        if ! list_contains "$VALID_SHELLS" "$shell"; then
            if passwd -S "$user" 2>/dev/null | grep -Evq '^\S*\sL\s' 2>/dev/null; then
                results+=("$user($shell)")
            fi
        fi
    done < <(awk -F: '($1 != "root") {print $1" "$7}' "$PASSWD_FILE")
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "Invalid shell accounts: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    while read -r user shell; do
        if ! list_contains "$VALID_SHELLS" "$shell"; then
            if passwd -S "$user" 2>/dev/null | grep -Evq '^\S*\sL\s' 2>/dev/null; then
                if usermod -L "$user" 2>/dev/null; then
                    fixd "Locked account $user"
                fi
            fi
        fi
    done < <(awk -F: '($1 != "root") {print $1" "$7}' "$PASSWD_FILE")
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi