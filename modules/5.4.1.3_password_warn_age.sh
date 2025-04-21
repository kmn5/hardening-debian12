#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.4.1.3 - Ensure password expiration warning days is configured"

LOGIN_FILE='/etc/login.defs'
SHADOW_FILE='/etc/shadow'
NUMBER_PATTERN='([7-9]|[1-9][0-9]+)'
LOGIN_PATTERN="^\s*PASS_WARN_AGE\s+$NUMBER_PATTERN\b"
SHADOW_AWK='($2~/^\$.+\$/) {if($6 < 7) print $1}'
LOGIN_OPTION='PASS_WARN_AGE=7'
CHAGE_PARAM='warndays'


audit() {
    if ! does_pattern_exist_in_file_nocase "$LOGIN_FILE" "$LOGIN_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    if [[ $(awk -F: "$SHADOW_AWK" "$SHADOW_FILE" 2>/dev/null) ]]; then
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
    while read -r user; do
        if chage --"$CHAGE_PARAM" "$value" "$user" 2>/dev/null; then
            fixd "Parameter $CHAGE_PARAM set to $value for $user"
        fi
    done < <(awk -F: "$SHADOW_AWK" "$SHADOW_FILE" 2>/dev/null)
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi