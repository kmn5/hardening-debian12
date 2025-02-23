#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

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


if ! audit && $SCRIPT_APPLY; then
    apply
fi