#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.1.4 - Ensure sshd access is configured"

PACKAGE='openssh-server'
SERVICE_NAME='sshd'
CONF_FILE='/etc/ssh/sshd_config.d/50-hardening.conf'
SSHD_PATTERN='^(allow|deny)(users|groups) \S+'
SSHD_PARAM='AllowGroups'
GROUP='ssh'
USER_ID='1000'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! sshd -T 2>/dev/null | grep -Eiq "$SSHD_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if ! getent group "$GROUP" 2>/dev/null 1>&2; then
        if groupadd -r "$GROUP" 2>/dev/null; then
            local username=$(id -nu "$USER_ID" 2>/dev/null)
            if [[ -n "$username" ]] && usermod -aG "$GROUP" "$username" 2>/dev/null; then
                info "Added group $GROUP with user $username"
            else
                info "Added group $GROUP"
            fi
        fi
    fi
    if ss -pntH | grep -q "\"$SERVICE_NAME\"" && ! $SCRIPT_FORCE; then
        warn "Active SSH sessions detected. Skipping sshd configuration"
        return
    fi
    if add_end_of_file "$CONF_FILE" "$SSHD_PARAM $GROUP"; then
        fixd "Parameter $SSHD_PARAM set to $GROUP in $CONF_FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi