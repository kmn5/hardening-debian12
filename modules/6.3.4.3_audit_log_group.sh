#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.3.4.3 - Ensure only authorized groups are assigned ownership of audit log files"

PACKAGE='auditd'
CONF_FILE='/etc/audit/auditd.conf'
GROUP='adm'
GROUPSOK='adm root'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local log_group=$(cat "$CONF_FILE" | awk -F '=' '/^\s*log_group/ {print $2}' | xargs)
    if [[ ! "$log_group" =~ ^($(echo $GROUPSOK | tr ' ' '|'))$ ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    for file in $log_dir/*; do
        [[ -f "$file" ]] || continue
        if ! has_file_one_of_ownerships "$file" "" "$GROUPSOK"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    local log_group=$(cat "$CONF_FILE" | awk -F '=' '/^\s*log_group/ {print $2}' | xargs)
    if [[ ! "$log_group" =~ ^($(echo $GROUPSOK | tr ' ' '|'))$ ]]; then
        if set_keyword_argument_in_file "$CONF_FILE" "log_group" "$GROUP" " = "; then
            systemctl restart auditd
            fixd "Parameter log_group set to $GROUP in $CONF_FILE"
        fi
    fi
    local log_dir=$(dirname $(cat "$CONF_FILE" | awk -F '=' '/^\s*log_file/ {print $2}' | xargs))
    for file in $log_dir/*; do
        [[ -f "$file" ]] || continue
        if ! has_file_one_of_ownerships "$file" "" "$GROUPSOK"; then
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