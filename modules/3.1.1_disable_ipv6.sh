#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="3.1.1 - Ensure IPv6 status is identified"

SYSCTL_PARAMS='net.ipv6.conf.all.disable_ipv6=1 net.ipv6.conf.default.disable_ipv6=1 net.ipv6.conf.lo.disable_ipv6=1'


audit() {
    if is_ipv6_enabled; then
        info "$DESCRIPTION" "IPv6 is enabled on this system."
        return 1
    fi
    info "$DESCRIPTION"
    warn "IETF RFC 4038 recommends that applications are built with an assumption of dual stack."
}


apply() {
    warn "Configure IPv6 in accordance with system requirements and local site policy."
    return
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