#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="0.1.2 - Ensure no pending reboot due to package or kernel update"

RUNNING_KERNEL="$(uname -r)"
LATEST_KERNEL="$(ls /boot/vmlinuz-* | sort -V | tail -n1 | sed 's|/boot/vmlinuz-||')"


audit() {
    if does_file_exist /var/run/reboot-required; then
        local packages="$(cat /var/run/reboot-required.pkgs)"
        crit "$DESCRIPTION" "Affected packages: $packages"
        return 1
    fi
    if [[ "$RUNNING_KERNEL" != "$LATEST_KERNEL" ]]; then
        crit "$DESCRIPTION" "Running kernel: $RUNNING_KERNEL" "Latest kernel: $LATEST_KERNEL"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Manually reboot system before proceeding"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi