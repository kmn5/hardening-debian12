#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=0

DESCRIPTION="0.1.2 - Ensure no pending reboot due to package or kernel updates"

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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi