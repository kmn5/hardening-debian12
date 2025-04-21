#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="99.1.9.3 - Ensure systemd-resolved is configured"

PACKAGE='systemd-resolved'
CONF_FILE='/etc/systemd/resolved.conf'
OPTIONS='DNSOverTLS=yes LLMNR=no MulticastDNS=no'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for option in $OPTIONS; do
        param=$(echo "$option" | cut -d= -f 1)
        value=$(echo "$option" | cut -d= -f 2-)
        pattern="^\s*$param\s*=\s*$value\b"
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
        pattern="^\s*$param\s*=\s*$value\b"
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