#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.3.2.2 - Ensure audit logs are not automatically deleted"

PACKAGE='auditd'
CONF_FILE='/etc/audit/auditd.conf'
AUDIT_PARAM='max_log_file_action'
AUDIT_VALUE='keep_logs'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! does_pattern_exist_in_file "$CONF_FILE" "^$AUDIT_PARAM *= *$AUDIT_VALUE"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if set_keyword_argument_in_file "$CONF_FILE" "$AUDIT_PARAM" "$AUDIT_VALUE" " = "; then
        fixd "Parameter $AUDIT_PARAM set to $AUDIT_VALUE in $CONF_FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi