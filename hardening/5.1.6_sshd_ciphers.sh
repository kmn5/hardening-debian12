#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.1.6 - Ensure sshd Ciphers are configured"

PACKAGE='openssh-server'
SERVICE_NAME='sshd'
CONF_FILE='/etc/ssh/sshd_config.d/50-hardening.conf'
CONF_PARAM='Ciphers'
BAD_VALUES='3des-cbc aes128-cbc aes192-cbc aes256-cbc'


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


if ! audit && $SCRIPT_APPLY; then
    apply
fi