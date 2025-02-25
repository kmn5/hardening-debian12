#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.3.11 - Ensure session initiation information is collected"

PACKAGE='auditd'
AUDIT_PARAMS='-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session'
RULES_FIND='/etc/audit/rules.d/*.rules'
RULES_FILE='/etc/audit/rules.d/50-session.rules'


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


if ! audit && $SCRIPT_APPLY; then
    apply
fi