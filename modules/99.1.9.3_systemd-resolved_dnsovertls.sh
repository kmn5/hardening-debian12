#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="99.1.9.3 - Ensure DNSOverTLS is configured"

PACKAGE='systemd-resolved'
CONF_FILE='/etc/systemd/resolved.conf'
PARAM='DNSOverTLS'
VALUE='yes'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! does_pattern_exist_in_file "$CONF_FILE" "^\s*$PARAM\s*=\s*$VALUE\b"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if set_keyword_argument_in_file "$CONF_FILE" "$PARAM" "$VALUE" "="; then
        fixd "Parameter $PARAM set to $VALUE in $CONF_FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi