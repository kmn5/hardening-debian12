#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.1.4 - Ensure journald ForwardToSyslog is disabled"

CONF_FILE='/etc/systemd/journald.conf'
OPTIONS='ForwardToSyslog=no'


audit() {
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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi