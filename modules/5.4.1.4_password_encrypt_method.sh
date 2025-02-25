#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.1.4 - Ensure strong password hashing algorithm is configured"

LOGIN_FILE='/etc/login.defs'
LOGIN_PATTERN="^\s*ENCRYPT_METHOD\s+(SHA512|YESCRYPT)\b"
LOGIN_OPTION='ENCRYPT_METHOD=YESCRYPT'


audit() {
    if ! does_pattern_exist_in_file_nocase "$LOGIN_FILE" "$LOGIN_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local param=$(cut -d= -f 1 <<< "$LOGIN_OPTION")
    local value=$(cut -d= -f 2- <<< "$LOGIN_OPTION")
    if ! does_pattern_exist_in_file_nocase "$LOGIN_FILE" "$LOGIN_PATTERN"; then
        if set_keyword_argument_in_file "$LOGIN_FILE" "$param" "$value"; then
            fixd "Parameter $param set to $value in $LOGIN_FILE"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi