#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="4.1.6 - Ensure ufw firewall rules exist for all open ports"

PACKAGE='ufw'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local ufw_status=$(ufw status verbose)
    if ! echo "$ufw_status" | grep -q "Status: active"; then
        return
    fi
    local open_ports=$(ss -lntuH | grep -E -v '\s(127.0.0.1|::1|\[::1\]):' | perl -lne 'print "$2/$1" if /^(\w+)[^:]+\S+:(\d+)\s/' | sort -u)
    for port in $open_ports; do
        if ! echo "$ufw_status" | grep -q "^$port"; then
            crit "$DESCRIPTION" "$(echo $open_ports)"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    warn "Evaluate the service listening on the port and add a rule for accepting or denying"\
         "inbound connections in accordance with local site policy:"\
         " ufw allow in <port>/<tcp or udp protocol>"\
         " ufw deny in <port>/<tcp or udp protocol>"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi