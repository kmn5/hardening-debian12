#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="3.1.2 - Ensure wireless interfaces are disabled"
# Comment: Cannot use "is_kernel_module_enabled" due to how the wireless driver is baked into some kernels (eg RaspiOS)

audit() {
    if command -v nmcli >/dev/null 2>&1 && is_service_active "NetworkManager"; then
        if ! nmcli radio all 2>/dev/null | grep -Eq '\s*\S+\s+disabled\s+\S+\s+disabled\b'; then
            crit "$DESCRIPTION"
            return 1
        fi
    elif [[ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]]; then
        mname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)";done | sort -u)
        for dm in $mname; do
            if ! grep -Eq "^\s*install\s+$dm\s+/bin/(true|false)" /etc/modprobe.d/*.conf 2>/dev/null; then
                crit "$DESCRIPTION"
                return 1
            fi
        done
    fi
    pass "$DESCRIPTION"
}


apply() {
    if command -v nmcli >/dev/null 2>&1 && is_service_active "NetworkManager"; then
        if nmcli radio all off 2>/dev/null 2>&1; then
            fixd "Disabled all radio via nmcli"
        fi
    elif [[ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]]; then
        mname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)";done | sort -u)
        for dm in $mname; do
            if write_to_file /etc/modprobe.d/$dm.conf "install $dm /bin/true"; then
                fixd "Faked install in /etc/modprobe.d/$dm.conf"
            fi
            if add_end_of_file /etc/modprobe.d/blacklist.conf "blacklist $dm"; then
                fixd "Blacklisted module in /etc/modprobe.d/blacklist.conf"
            fi
        done
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi