#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="3.3.11 - Ensure ipv6 router advertisements are not accepted"

SYSCTL_PARAMS='net.ipv6.conf.all.accept_ra=0 net.ipv6.conf.default.accept_ra=0'
SYSCTL_FILE='50-net.conf'


audit() {
    for sysctl_values in $SYSCTL_PARAMS; do
        sysctl_param=$(echo "$sysctl_values" | cut -d= -f 1)
        sysctl_exp_result=$(echo "$sysctl_values" | cut -d= -f 2)
        if [[ "$sysctl_param" =~ .*ipv6.* ]] && ! is_ipv6_enabled; then
            continue
        fi
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
        if [[ "$sysctl_param" =~ .*ipv6.* ]] && ! is_ipv6_enabled; then
            continue
        fi
        if set_sysctl_param "$sysctl_param" "$sysctl_exp_result" "$SYSCTL_FILE"; then
            fixd "Sysctl parameter $sysctl_param set to $sysctl_exp_result"
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi