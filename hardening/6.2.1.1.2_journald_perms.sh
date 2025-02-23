#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.1.1.2  - Ensure journald log file access is configured"

CONF_FILE='/etc/tmpfiles.d/systemd.conf'
ALT_CONF_FILE='/usr/lib/tmpfiles.d/systemd.conf'
TMPFILESD_PATTERN='^z *\/var\/log\/journal\/%m\/\*\.journal *(0640|0600) *root *systemd-journal'
TMPFILESD_REPLACE_PATTERN='^z *\/var\/log\/journal\/%m\/(.*journal|\*)'
TMPFILESD_LINE='z /var/log/journal/%m/*.journal 0640 root systemd-journal - -'


audit() {
    local conf_file="$CONF_FILE"
    if [[ ! -f "$conf_file" ]]; then
        conf_file="$ALT_CONF_FILE"
    fi
    if ! does_pattern_exist_in_file "$conf_file" "$TMPFILESD_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if [[ ! -f "$CONF_FILE" ]]; then
        if ! cp -a "$ALT_CONF_FILE" "$CONF_FILE"; then
            return
        fi
    fi
    if comment_replace_pattern_in_file "$CONF_FILE" "$TMPFILESD_REPLACE_PATTERN" "$TMPFILESD_LINE"; then
        fixd "Default journald log permissions set in $CONF_FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi