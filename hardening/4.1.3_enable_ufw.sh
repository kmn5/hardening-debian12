#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="4.1.3 - Ensure ufw service is enabled"

PACKAGE='ufw'
SERVICE_NAME='ufw.service'
SSH_SERVICE='sshd'
SSH_DEFAULT_PORT=22
SSH_CONF_FIND='/etc/ssh/sshd_config /etc/ssh/sshd_config.d/*'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! is_service_enabled "$SERVICE_NAME" || ! is_service_active "$SERVICE_NAME" || ! ufw status 2>/dev/null | grep -q "Status: active"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    for file in $SSH_CONF_FIND; do
        local ssh_port=$(awk '$1=="Port"{print $2}' "$file" 2>/dev/null)
        if [[ $ssh_port != "" && $ssh_port != "$SSH_DEFAULT_PORT" ]]; then
            warn "Non standard ssh port detected in $file ($ssh_port). Skipping ufw configuration"
            return
        fi
    done
    local ssh_port=$(ss -plntuH | grep "$SSH_SERVICE" | perl -lne 'print "$3" if /(\d+(.|:)){4}(\d+)/' | head -n 1)
    if [[ $ssh_port != "$SSH_DEFAULT_PORT" ]]; then
        warn "Non standard port detected for $SSH_SERVICE service ($ssh_port). Skipping ufw configuration"
        return
    fi
    if ! is_service_enabled "$SERVICE_NAME" || ! is_service_active "$SERVICE_NAME"; then
        if systemctl unmask "$SERVICE_NAME" 2>/dev/null && systemctl --now enable "$SERVICE_NAME" 2>/dev/null; then
            fixd "Enabled $SERVICE_NAME daemon"
        fi
    fi
    if ufw allow $SSH_DEFAULT_PORT/tcp 2>/dev/null 1>&2; then
        fixd "Added anti-lockout rule for ssh (ufw allow $SSH_DEFAULT_PORT/tcp)"
    else
        return 1 # something went wrong
    fi
    if ufw --force enable 2>/dev/null 1>&2; then
        fixd "Started ufw firewall"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi