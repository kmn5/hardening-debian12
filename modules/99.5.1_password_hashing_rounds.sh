#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=3

DESCRIPTION="99.5.1 - Ensure password hashing rounds is configured"

LOGIN_FILE='/etc/login.defs'
LOGIN_PATTERNS="^\s*SHA_CRYPT_MIN_ROUNDS\b ^\s*SHA_CRYPT_MAX_ROUNDS\b"
LOGIN_OPTIONS='SHA_CRYPT_MIN_ROUNDS=50000 SHA_CRYPT_MAX_ROUNDS=100000'


audit() {
    for login_pattern in $LOGIN_PATTERNS; do
        if ! does_pattern_exist_in_file_nocase "$LOGIN_FILE" "$login_pattern"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for login_options in $LOGIN_OPTIONS; do
        local param=$(cut -d= -f 1 <<< "$login_options")
        local value=$(cut -d= -f 2- <<< "$login_options")
        if ! does_pattern_exist_in_file_nocase "$LOGIN_FILE" "^\s*$param\b"; then
            if set_keyword_argument_in_file "$LOGIN_FILE" "$param" "$value"; then
                fixd "Parameter $param set to $value in $LOGIN_FILE"
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