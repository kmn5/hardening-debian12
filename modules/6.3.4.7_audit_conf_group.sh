#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.3.4.7 - Ensure audit configuration files belong to group root"

PACKAGE='auditd'
CONF_FIND='/etc/audit/*.conf /etc/audit/*/*.conf /etc/audit/*.rules /etc/audit/*/*.rules'
GROUP='root'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $CONF_FIND; do
        [[ -f "$file" ]] || continue
        if ! has_file_correct_ownership "$file" "" "$GROUP"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $CONF_FIND; do
        [[ -f "$file" ]] || continue
        if ! has_file_correct_ownership "$file" "" "$GROUP"; then
            if chgrp "$GROUP" "$file"; then
                fixd "Group ownership for $file set to $GROUP"
            fi
        fi
    done
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi