#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.1.7 - Ensure sshd ClientAliveInterval and ClientAliveCountMax are configured"

PACKAGE='openssh-server'
SERVICE_NAME='sshd'
CONF_FILE='/etc/ssh/sshd_config.d/50-hardening.conf'
SSHD_PATTERNS='^clientaliveinterval[[:space:]]([1-9]|1[1-5])$ ^clientalivecountmax[[:space:]][1-2]$'
SSHD_OPTIONS='ClientAliveInterval=15 ClientAliveCountMax=2'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for pattern in $SSHD_PATTERNS; do
        if ! sshd -T 2>/dev/null | grep -Eiq "$pattern"; then
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
    patterns=($SSHD_PATTERNS)
    options=($SSHD_OPTIONS)
    for ((i=0; i<${#patterns[@]}; i++)); do
        if ! sshd -T 2>/dev/null | grep -Eiq "${patterns[$i]}"; then
            local param=$(cut -d= -f 1 <<< "${options[$i]}")
            local value=$(cut -d= -f 2- <<< "${options[$i]}")
            if set_keyword_argument_in_file "$CONF_FILE" "$param" "$value"; then
                fixd "Parameter $param set to $value in $CONF_FILE"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi