#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.1.3 - Ensure journald log file rotation is configured"

PACKAGE='systemd-journal-remote'
CONF_FILE='/etc/systemd/journald.conf'
LOG_DIR='/var/log/journal'
OPTIONS='SystemMaxUse=30%/5% SystemKeepFree=5%/15% RuntimeMaxUse=5%/5% RuntimeKeepFree=10%/15% MaxFileSec=1month'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for option in $OPTIONS; do
        param=$(echo "$option" | cut -d= -f 1)
        pattern="^$param="
        if ! does_pattern_exist_in_file "$CONF_FILE" "$pattern"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    local df_output=$(df -B 1 --output=size,target "$LOG_DIR" | tail -n1)
    local partition=$(echo "$df_output" | awk '{print $2}')
    local partition_size=$(echo "$df_output" | awk '{print $1}')
    local memory_size=$(free -b | grep 'Mem:' | awk '{print $2}')
    for option in $OPTIONS; do
        param=$(echo "$option" | cut -d= -f 1)
        pattern="^$param="
        if ! does_pattern_exist_in_file "$CONF_FILE" "$pattern"; then
            if [[ "$partition" == '/var/log*' ]]; then
                value=$(echo "$option" | cut -d= -f 2- | cut -d/ -f 1)
            else
                value=$(echo "$option" | cut -d= -f 2- | cut -d/ -f 2)
            fi
            if [[ "$value" == *'%' && "$param" == 'System'* ]]; then
                value=$(numfmt --to iec "$(("$partition_size" * "${value//%}" / 100))")
            elif [[ "$value" == *'%' && "$param" == 'Runtime'* ]]; then
                value=$(numfmt --to iec "$(("$memory_size" * "${value//%}" / 100))")
            fi
            if set_keyword_argument_in_file "$CONF_FILE" "$param" "$value" "="; then
                fixd "Parameter $param set to $value in $CONF_FILE"
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