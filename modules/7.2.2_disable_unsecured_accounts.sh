#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="7.2.2 - Ensure /etc/shadow password fields are not empty"

FILE='/etc/shadow'
PATTERN='^[^:]+::'
USER_ID='1000'


audit() {
    if does_pattern_exist_in_file "$FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local username=$(id -nu "$USER_ID" 2>/dev/null)
    for passwordless_user in $(grep -E "$PATTERN" "$FILE" | cut -d: -f1 2>/dev/null); do
        if [[ "$passwordless_user" != "$username" ]] && passwd -l "$passwordless_user" 2>/dev/null 1>&2; then
            fixd "Locked account $passwordless_user"
        fi
    done
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi