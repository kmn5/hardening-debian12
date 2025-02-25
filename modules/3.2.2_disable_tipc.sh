#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="3.2.2 - Ensure tipc kernel module is not available"

MODULE_NAME='tipc'


audit() {
    if is_kernel_module_enabled "$MODULE_NAME"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if write_to_file /etc/modprobe.d/$MODULE_NAME.conf "install $MODULE_NAME /bin/true"; then
        fixd "Faked install in /etc/modprobe.d/$MODULE_NAME.conf"
    fi
    if add_end_of_file /etc/modprobe.d/blacklist.conf "blacklist $MODULE_NAME"; then
        fixd "Blacklisted module in /etc/modprobe.d/blacklist.conf"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi