#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="3.3.4 - Ensure broadcast icmp requests are ignored"

SYSCTL_PARAMS='net.ipv4.icmp_echo_ignore_broadcasts=1'
SYSCTL_FILE='50-net.conf'


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


if ! audit && $SCRIPT_APPLY; then
    apply
fi