#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="2.3.3.2 - Ensure chrony is running as user _chrony"

PACKAGE='chrony'
PROCESS_NAME='chronyd'
USER_NAME='_chrony'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! is_process_running_as_user "$PROCESS_NAME" "$USER_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    :
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi