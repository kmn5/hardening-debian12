#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="1.5.2 - Ensure ptrace_scope is restricted"

SYSCTL_PARAM='kernel.yama.ptrace_scope'
SYSCTL_EXP_RESULT=1
SYSCTL_FILE='50-kernel.conf'


audit() {
    if ! has_sysctl_param_expected_result "$SYSCTL_PARAM" "$SYSCTL_EXP_RESULT"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if set_sysctl_param "$SYSCTL_PARAM" "$SYSCTL_EXP_RESULT" "$SYSCTL_FILE"; then
        fixd "Sysctl parameter $SYSCTL_PARAM set to $SYSCTL_EXP_RESULT"
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