#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

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


if ! audit && $SCRIPT_APPLY; then
    apply
fi