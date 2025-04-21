#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="6.3.3.19 - Ensure kernel module loading unloading and modification is collected"

PACKAGE='auditd'
UID_MIN=$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)
AUDIT_PARAMS="-a always,exit -F arch=b64 -S init_module,delete_module,finit_module -F auid>=$UID_MIN -F auid!=unset -k kernel_modules
-a always,exit -F path=/usr/bin/kmod -F perm=x -F auid>=$UID_MIN -F auid!=unset -k kernel_modules"
RULES_FIND='/etc/audit/rules.d/*.rules'
RULES_FILE='/etc/audit/rules.d/50-kernel_modules.rules'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    # define custom IFS and save default one
    default_IFS=$IFS
    custom_IFS=$'\n'
    IFS=$custom_IFS
    for param in $AUDIT_PARAMS; do
        IFS=$default_IFS
        search_res=0
        for file in $RULES_FIND; do
            if does_pattern_exist_in_file "$file" "$param"; then
                search_res=1
                break
            fi
        done
        if [[ "$search_res" = 0 ]]; then
            crit "$DESCRIPTION"
            IFS=$default_IFS
            return 1
        fi
        IFS=$custom_IFS
    done
    pass "$DESCRIPTION"
    IFS=$default_IFS
}


apply() {
    # define custom IFS and save default one
    default_IFS=$IFS
    custom_IFS=$'\n'
    IFS=$custom_IFS
    for param in $AUDIT_PARAMS; do
        IFS=$default_IFS
        search_res=0
        for file in $RULES_FIND; do
            if does_pattern_exist_in_file "$file" "$param"; then
                search_res=1
                break
            fi
        done
        if [[ "$search_res" = 0 ]]; then
            if add_end_of_file "$RULES_FILE" "$param"; then
                fixd "Audit rule \"$param\" added to $RULES_FILE"
            fi
        fi
        IFS=$custom_IFS
    done
    IFS=$default_IFS
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi