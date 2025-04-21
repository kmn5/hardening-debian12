#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=4

DESCRIPTION="1.5.3 - Ensure core dumps are restricted"

CONF_FILE='/etc/security/limits.d/50-core_dumps.conf'
CONF_FIND='/etc/security/limits.conf /etc/security/limits.d/*.conf'
CONF_PATTERN='^\s*\*\s+hard\s+core\s+0\b'
SYSCTL_PARAM='fs.suid_dumpable'
SYSCTL_EXP_RESULT=0
SYSCTL_FILE='50-fs.conf'

 
audit() {
    search_res=0
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file "$file" "$CONF_PATTERN"; then
            search_res=1
            break
        fi
    done
    if [[ "$search_res" = 0 ]] || ! has_sysctl_param_expected_result "$SYSCTL_PARAM" "$SYSCTL_EXP_RESULT"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    search_res=0
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file "$file" "$CONF_PATTERN"; then
            search_res=1
            break
        fi
    done
    if [[ "$search_res" = 0 ]]; then
        if add_end_of_file "$CONF_FILE" "* hard core 0"; then
            fixd "Disabled core dumps in security limits"
        fi
    fi
    if ! has_sysctl_param_expected_result "$SYSCTL_PARAM" "$SYSCTL_EXP_RESULT"; then
        if set_sysctl_param "$SYSCTL_PARAM" "$SYSCTL_EXP_RESULT" "$SYSCTL_FILE"; then
            fixd "Sysctl parameter $SYSCTL_PARAM set to $SYSCTL_EXP_RESULT"
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