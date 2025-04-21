#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=3

DESCRIPTION="2.3.4.1 - Ensure ntp access control is configured (deprecated)"

PACKAGE='ntp'
NTP_CONF_DEFAULT_PATTERN='^restrict -4 default (kod nomodify notrap nopeer noquery|kod notrap nomodify nopeer noquery|ignore)'
NTP_CONF_FILE='/etc/ntpsec/ntp.conf'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! does_pattern_exist_in_file "$NTP_CONF_FILE" "$NTP_CONF_DEFAULT_PATTERN"; then
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