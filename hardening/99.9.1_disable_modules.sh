#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="99.9.1 - Ensure loading and unloading of kernel modules at runtime is disabled"

SYSCTL_PARAMS='kernel.modules_disabled=1'
SYSTEMD_FILE='/etc/systemd/system/modules-disabled.service'
SYSTEMD_CONTENT='[Unit]
Description=Disables loading and unloading of kernel modules at runtime
DefaultDependencies=no
Conflicts=shutdown.target
After=network-pre.target
Before=network-online.target shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/sysctl -w kernel.modules_disabled=1
TimeoutSec=5s

[Install]
WantedBy=multi-user.target'


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
    if write_to_file "$SYSTEMD_FILE" "$SYSTEMD_CONTENT"; then
        local service_name=$(basename "$SYSTEMD_FILE")
        if systemctl unmask "$service_name" 2>/dev/null && systemctl --now enable "$service_name" 2>/dev/null; then
            fixd "Enabled $service_name daemon"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi