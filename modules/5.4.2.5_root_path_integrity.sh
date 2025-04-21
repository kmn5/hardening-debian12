#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=4

DESCRIPTION="5.4.2.5 - Ensure root path integrity"

PATTERN='(::|:\s*$|(\s+|:)\.(:|\s*$))'
USER='root'
PERMISSIONS='755'


audit() {
    if ! command -v sudo >/dev/null 2>&1; then
        info "$DESCRIPTION"
        warn "Sudo command not found. Skipping check"
        return
    fi
    local root_path=$(sudo -Hiu root env | grep '^PATH' | cut -d= -f2)
    if grep -Eq "$PATTERN" 2>/dev/null <<< "$root_path"; then
        crit "$DESCRIPTION"
        return 1
    fi
    while read -r path; do
        if ! has_file_correct_ownership "$path" "$USER" ""; then
            crit "$DESCRIPTION"
            return 1
        fi
        if ! has_file_less_permissions "$path" "$PERMISSIONS"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done < <(tr ':' '\n' <<< "$root_path")
    pass "$DESCRIPTION"
}


apply() {
    local root_path=$(sudo -Hiu root env | grep '^PATH' | cut -d= -f2)
    if grep -Eq "$PATTERN" 2>/dev/null <<< "$root_path"; then
        warn  "Sanitize the root path by removing a trailing (:), empty (::) and working directory (.)"
    fi
    while read -r path; do
        if ! has_file_correct_ownership "$path" "$USER" ""; then
            if chown "$USER" "$path"; then
                fixd "Ownership for $path set to $USER"
            fi
        fi
        if ! has_file_less_permissions "$path" "$PERMISSIONS"; then
            if chmod 0"$PERMISSIONS" "$path";then
                fixd "Setting $path permissions to $PERMISSIONS"
            fi
        fi
    done < <(tr ':' '\n' <<< "$root_path")
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi