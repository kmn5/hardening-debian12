#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

DESCRIPTION="5.1.15 - Ensure sshd MACs are configured"

PACKAGE='openssh-server'
SERVICE_NAME='sshd'
CONF_FILE='/etc/ssh/sshd_config.d/50-hardening.conf'
CONF_PARAM='MACs'
BAD_VALUES='hmac-md5 hmac-md5-96 hmac-ripemd160 hmac-sha1 hmac-sha1-96 umac-64@openssh.com umac-128@openssh.com hmac-md5-etm@openssh.com hmac-md5-96-etm@openssh.com hmac-ripemd160-etm@openssh.com hmac-sha1-etm@openssh.com hmac-sha1-96-etm@openssh.com umac-64-etm@openssh.com umac-128-etm@openssh.com'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local conf_values=$(sshd -T 2>/dev/null | grep -i "^$CONF_PARAM ")
    for value in $BAD_VALUES; do
        if echo "$conf_values" | grep -Eq "(,|\s)$value(,|$)"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    if ss -pntH | grep -q "\"$SERVICE_NAME\"" && ! $SCRIPT_FORCE; then
        return
    fi
    local conf_values=$(sshd -T 2>/dev/null | grep -i "^$CONF_PARAM " 2>/dev/null | cut -d' ' -f 2)
    for value in $BAD_VALUES; do
        conf_values=$(sed -r "s/(^|,)$value(,|$)/,/" <<< "$conf_values" | sed -e 's/^,//' -e 's/,$//')
    done
    if set_keyword_argument_in_file "$CONF_FILE" "$CONF_PARAM" "$conf_values"; then
        fixd "Parameter $CONF_PARAM set to $conf_values in $CONF_FILE"
    fi
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi