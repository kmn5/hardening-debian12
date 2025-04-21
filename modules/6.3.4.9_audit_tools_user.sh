#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.3.4.9 - Ensure audit tools are owned by root"

PACKAGE='auditd'
AUDIT_TOOLS='/sbin/auditctl /sbin/aureport /sbin/ausearch /sbin/autrace /sbin/auditd /sbin/augenrules'
USER='root'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for file in $AUDIT_TOOLS; do
        [[ -f "$file" ]] || continue
        if ! has_file_correct_ownership "$file" "$USER" ""; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $AUDIT_TOOLS; do
        [[ -f "$file" ]] || continue
        if ! has_file_correct_ownership "$file" "$USER" ""; then
            if chown "$USER" "$file"; then
                fixd "User ownership for $file set to $USER"
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