#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.3.4.2 - Ensure ntp is configured with authorized timeserver (deprecated)"

PACKAGE='ntp'
NTP_CONF_DEFAULT_PATTERN='^\s*(server|pool)\s+\S+'
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
    warn "Manually configure chrony yourself"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi