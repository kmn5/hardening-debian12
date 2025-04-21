#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi