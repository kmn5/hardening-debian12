#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.4.2.2 - Ensure root is the only GID 0 account"

PASSWD_FILE='/etc/passwd'


audit() {
    if [[ $(id -g root 2>/dev/null) != "0" ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    if [[ $(getent group root 2>/dev/null | cut -d: -f3) != "0" ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    local results=()
    while read -r user gid; do
        if [[ "$gid" == "0" && "$user" != "root" ]]; then
            results+=("$user")
        fi
    done < <(awk -F: '($1 !~ /^(sync|shutdown|halt|operator)/) {print $1" "$4}' "$PASSWD_FILE")
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "GID 0 users: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if [[ $(id -g root 2>/dev/null) != "0" ]]; then
        if usermod -g 0 root 2>/dev/null; then
            fixd "GID for user root set to 0"
        fi
    fi
    if [[ $(getent group root 2>/dev/null | cut -d: -f3) != "0" ]]; then
        if groupmod -g 0 root 2>/dev/null; then
            fixd "GID for group root set to 0"
        fi
    fi
    warn "Remove any users other than the root user with GID 0 or assign them a new GID if appropriate"
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi