#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.1.3.3* - Ensure journald ForwardToSyslog is configured"

PACKAGE='rsyslog'
CONF_FILE='/etc/systemd/journald.conf'
OPTIONS='ForwardToSyslog=yes'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for option in $OPTIONS; do
        param=$(echo "$option" | cut -d= -f 1)
        value=$(echo "$option" | cut -d= -f 2-)
        pattern="^$param=.*$value"
        if ! does_pattern_exist_in_file "$CONF_FILE" "$pattern"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for option in $OPTIONS; do
        param=$(echo "$option" | cut -d= -f 1)
        value=$(echo "$option" | cut -d= -f 2-)
        pattern="^$param=$value"
        if ! does_pattern_exist_in_file "$CONF_FILE" "$pattern"; then
            if set_keyword_argument_in_file "$CONF_FILE" "$param" "$value" "="; then
                fixd "Parameter $param set to $value in $CONF_FILE"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi