#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=4

DESCRIPTION="99.1.8.2 - Ensure sysstat log umask is configured"

PACKAGE='sysstat'
FILE='/etc/sysstat/sysstat'
PATTERN="^\s*UMASK=[0-7]?[0-7]([01][0-7]|[0-7][0-6])\b"
OPTION='UMASK=0027'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if does_pattern_exist_in_file_nocase "$FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local param=$(cut -d= -f 1 <<< "$OPTION")
    local value=$(cut -d= -f 2- <<< "$OPTION")
    if does_pattern_exist_in_file_nocase "$FILE" "$PATTERN"; then
        if set_keyword_argument_in_file "$FILE" "$param" "$value" "="; then
            fixd "Parameter $param set to $value in $FILE"
        fi
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