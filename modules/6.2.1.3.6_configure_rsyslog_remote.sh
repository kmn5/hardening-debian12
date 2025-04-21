#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.3.6* - Ensure rsyslog is configured to send logs to a remote log host"

PACKAGE='rsyslog'
CONF_FIND='/etc/rsyslog.d/*.conf /etc/rsyslog.conf'
PATTERN='(^\s*[^#\s]+\s+@{1,2}\S+|^\s*[^#\s]+\s+action\([^#\)]*target="?[^#\s"]+"?)'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_multiline "$file" "$PATTERN"; then
            pass "$DESCRIPTION"
            return
        fi
    done
    crit "$DESCRIPTION"
    return 1
}


apply() {
    warn 'Edit the /etc/rsyslog.conf or /etc/rsyslog.d/*.conf files and add the following line'\
         '*.* action(type="omfwd" target="example.com" port="514" protocol="tcp"'\
         '           queue.type="linkedlist" queue.saveOnShutdown="on" action.resumeRetryCount="-1")'
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi