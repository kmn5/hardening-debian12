#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.1.3.7* - Ensure rsyslog is not configured to receive logs from a remote client"

PACKAGE='rsyslog'
CONF_FIND='/etc/rsyslog.d/*.conf /etc/rsyslog.conf'
PATTERN='^ *(\$ModLoad +im(udp|tcp)|\$Input(UDP|TCP)ServerRun|module\([^#\)]*load="?im(udp|tcp)|input\([^#\)]*type="?im(udp|tcp))'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file "$file" "$PATTERN"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file "$file" "$PATTERN"; then
            if comment_out_pattern_in_file "$file" "$PATTERN"; then
                fixd "Removed input module/server configs from $file"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi