#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

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


if ! audit && $SCRIPT_APPLY; then
    apply
fi