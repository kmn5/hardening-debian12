#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.4.2 - Ensure only authorized users own audit log files"

PACKAGE='auditd'
CONF_FILE='/etc/audit/auditd.conf'
USER='root'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    for file in $log_dir/*; do
        [[ -f "$file" ]] || continue
        if ! has_file_correct_ownership "$file" "$USER" ""; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    for file in $log_dir/*; do
        [[ -f "$file" ]] || continue
        if ! has_file_correct_ownership "$file" "$USER" ""; then
            if chown "$USER" "$file"; then
                fixd "User ownership for $file set to $USER"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi