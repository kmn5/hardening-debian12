#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.5.1 - Ensure address space layout randomization (ASLR) is enabled"

SYSCTL_PARAM='kernel.randomize_va_space'
SYSCTL_EXP_RESULT=2
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


if ! audit && $SCRIPT_APPLY; then
    apply
fi