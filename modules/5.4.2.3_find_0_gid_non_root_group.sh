#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.4.2.3 - Ensure group root is the only GID 0 group"

GROUP_FILE='/etc/group'


audit() {
    if [[ $(getent group root 2>/dev/null | cut -d: -f3) != "0" ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    local results=()
    while read -r group gid; do
        if [[ "$gid" == "0" && "$group" != "root" ]]; then
            results+=("$group")
        fi
    done < <(awk -F: '{print $1" "$3}' "$GROUP_FILE")
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "GID 0 groups: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if [[ $(getent group root 2>/dev/null | cut -d: -f3) != "0" ]]; then
        if groupmod -g 0 root 2>/dev/null; then
            fixd "GID for group root set to 0"
        fi
    fi
    warn "Remove any groups other than the root group with GID 0 or assign them a new GID if appropriate"
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi