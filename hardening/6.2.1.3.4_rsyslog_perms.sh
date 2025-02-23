#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.1.3.4* - Ensure rsyslog log file access is configured"

PACKAGE='rsyslog'
CONF_FILE='/etc/rsyslog.d/50-file_access.conf'
CONF_FIND='/etc/rsyslog.d/*.conf /etc/rsyslog.conf'
OPTIONS='$FileCreateMode=(0640|0600)'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local
    for option in $OPTIONS; do
        search_res=0
        param=$(echo "$option" | cut -d= -f 1)
        pattern=$(echo "$option" | cut -d= -f 2-)
        for file in $CONF_FIND; do
            if does_pattern_exist_in_file "$file" "^\s*$param\s+$pattern"; then
                search_res=1
                break
            fi
        done
        if [[ "$search_res" = 0 ]]; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for option in $OPTIONS; do
        conf_file="$CONF_FILE"
        param=$(echo "$option" | cut -d= -f 1)
        pattern=$(echo "$option" | cut -d= -f 2-)
        value=$(echo "$pattern" | tr -d '()' | cut -d'|' -f 1)
        for file in $CONF_FIND; do
            if does_pattern_exist_in_file "$file" "^\s*$param\s+"; then 
                conf_file="$file"
                break
            fi
        done
        if set_keyword_argument_in_file "$CONF_FILE" "$param" "$value"; then
            fixd "Parameter $param set to $value in $CONF_FILE"
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi