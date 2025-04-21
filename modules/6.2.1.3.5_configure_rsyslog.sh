#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.3.5* - Ensure rsyslog logging is configured"

PACKAGE='rsyslog'
CONF_FILE='/etc/rsyslog.d/50-logging.conf'
CONF_FIND='/etc/rsyslog.d/*.conf /etc/rsyslog.conf'
OPTIONS='*.*;auth,authpriv.none=-/var/log/syslog auth,authpriv.*=/var/log/auth.log cron.*=-/var/log/cron.log mail.*=-/var/log/mail.log kern.*=-/var/log/kern.log user.*=-/var/log/user.log *.emerg=:omusrmsg:*'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for option in $OPTIONS; do
        search_res=0
        escaped_param=$(echo "$option" | cut -d= -f 1 | sed 's@[]\/$*.^[]@\\&@g')
        for file in $CONF_FIND; do
            if does_pattern_exist_in_file "$file" "^\s*$escaped_param\s+\S*"; then
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
        search_res=0
        param=$(echo "$option" | cut -d= -f 1)
        escaped_param=$(sed 's@[]\/$*.^[]@\\&@g' <<< "$param")
        value=$(echo "$option" | cut -d= -f 2-)
        for file in $CONF_FIND; do
            if does_pattern_exist_in_file "$file" "^\s*$escaped_param\s+"; then 
                search_res=1
                break
            fi
        done
        if [[ "$search_res" = 0 ]]; then
            if set_keyword_argument_in_file "$CONF_FILE" "$param" "$value"; then
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