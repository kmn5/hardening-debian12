#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="7.2.3 - Ensure all groups in /etc/passwd exist in /etc/group"

PASSWD_FILE='/etc/passwd'


GROUP_FILE='/etc/group'
PASSWD_FILE='/etc/passwd'


audit() {
    local local_groups=$(cut -d: -f3 "$GROUP_FILE" | sort -u)
    local passwd_groups=$(cut -d: -f4 "$PASSWD_FILE" | sort -u)
    local missing_groups=$(comm -23 <(echo "$passwd_groups") <(echo "$local_groups"))
    if [[ -n "$missing_groups" ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local local_groups=$(cut -d: -f3 "$GROUP_FILE" | sort -u)
    while IFS=: read -r user group; do
        if ! grep -xq "$group" <<< "$local_groups"; then
            if usermod -g nogroup "$user" 2>/dev/null; then
                fixd "Primary group for user $user set to nogroup"
            fi
        fi
    done <<< "$(cut -d: -f1,4 "$PASSWD_FILE")"

}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi