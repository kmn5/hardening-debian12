#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=4

DESCRIPTION="99.1.8.4 - Ensure additional sysstat cron job is disabled"

PACKAGE='sysstat'
FILE='/etc/cron.d/sysstat'
PATTERN='^[^#[:space:]].*'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if does_pattern_exist_in_file "$FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if comment_out_pattern_in_file "$FILE" "$PATTERN"; then
        fixd "Disabled sysstat cron file $FILE"
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