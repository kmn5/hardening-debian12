#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=3

DESCRIPTION="99.3.2 - Ensure writing to FIFOs is restricted"

SYSCTL_PARAMS='fs.protected_fifos=2'
SYSCTL_FILE='50-fs.conf'


audit() {
    for sysctl_values in $SYSCTL_PARAMS; do
        sysctl_param=$(echo "$sysctl_values" | cut -d= -f 1)
        sysctl_exp_result=$(echo "$sysctl_values" | cut -d= -f 2)
        if ! has_sysctl_param_expected_result "$sysctl_param" "$sysctl_exp_result"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for sysctl_values in $SYSCTL_PARAMS; do
        sysctl_param=$(echo "$sysctl_values" | cut -d= -f 1)
        sysctl_exp_result=$(echo "$sysctl_values" | cut -d= -f 2)
        if set_sysctl_param "$sysctl_param" "$sysctl_exp_result" "$SYSCTL_FILE"; then
            fixd "Sysctl parameter $sysctl_param set to $sysctl_exp_result"
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