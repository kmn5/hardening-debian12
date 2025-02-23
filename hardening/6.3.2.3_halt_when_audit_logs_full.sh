#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.2.3 - Ensure system is disabled when audit logs are full"

PACKAGE='auditd'
CONF_FILE='/etc/audit/auditd.conf'
AUDIT_OPTIONS='disk_full_action=(HALT|SINGLE) disk_error_action=(SYSLOG|HALT|SINGLE)'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for option in $AUDIT_OPTIONS; do
        audit_param=$(echo "$option" | cut -d= -f 1)
        audit_pattern=$(echo "$option" | cut -d= -f 2-)
        if ! does_pattern_exist_in_file_nocase "$CONF_FILE" "^$audit_param\s*=\s*$audit_pattern\b"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for option in $AUDIT_OPTIONS; do
        audit_param=$(echo "$option" | cut -d= -f 1)
        audit_pattern=$(echo "$option" | cut -d= -f 2-)
        audit_value=$(echo "$audit_pattern" | tr -d '()' | cut -d'|' -f 1)
        if ! does_pattern_exist_in_file_nocase "$CONF_FILE" "^$audit_param\s*=\s*$audit_pattern\b"; then
            if set_keyword_argument_in_file "$CONF_FILE" "$audit_param" "$audit_value" " = "; then
                fixd "Parameter $audit_param set to $audit_value in $CONF_FILE"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi