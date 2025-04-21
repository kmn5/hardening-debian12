#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="2.3.4.3 - Ensure ntp is running as user ntp (deprecated)"

PACKAGE='ntp'
PROCESS_NAME='ntpd'
USER_NAME='ntp'
NTP_INIT_PATTERN='^RUNASUSER=ntp'
NTP_INIT_FILE='/etc/init.d/ntp'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if is_process_running_as_user "$PROCESS_NAME" "$USER_NAME"; then
        pass "$DESCRIPTION"
        return
    fi
    if does_pattern_exist_in_file "$NTP_INIT_FILE" "$NTP_INIT_PATTERN"; then
        pass "$DESCRIPTION"
        return
    fi
    crit "$DESCRIPTION"
    return 1
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