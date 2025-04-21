#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="1.1.1.5 - Ensure jffs2 kernel module is not available"

MODULE_NAME='jffs2'


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


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi