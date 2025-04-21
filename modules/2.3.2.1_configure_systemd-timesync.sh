#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="2.3.2.1 - Ensure systemd-timesyncd configured with authorized timeserver"

SERVICE_NAME='systemd-timesyncd.service'
CONF_PATTERN='^\s*(NTP|FallbackNTP)=\S+'
CONF_FIND='/etc/systemd/*.conf /etc/systemd/**/*.conf'
CONF_FILE='/etc/systemd/timesyncd.conf'


audit() {
    if ! is_service_enabled "$SERVICE_NAME"; then
        return
    fi
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file "$file" "$CONF_PATTERN"; then
            pass "$DESCRIPTION"
            return
        fi
    done
    crit "$DESCRIPTION"
    return 1
}


apply() {
    if set_keyword_argument_in_file "$CONF_FILE" "FallbackNTP" "0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org" "="; then
        fixd "Parameter FallbackNTP set to *.debian.pool.ntp.org in $CONF_FILE"
    fi
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi