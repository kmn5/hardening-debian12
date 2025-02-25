#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.1.21 - Ensure mail transfer agent is configured for local-only"
POSTFIX_CONFIG="/etc/postfix/main.cf"
EXIM4_CONFIG="/etc/exim4/update-exim4.conf.conf"


audit() {
    if [[ "$(ss -lntuH | grep -E ':25\s' | grep -E -v '\s(127.0.0.1|::1|\[::1\]):25\s' | wc -l)" -gt 0 ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local process=$(ss -plntuH | grep -E ':25\s' | head -n 1 | perl -lne 'print "$1" if /users:\(\("(\w+)"/')
    if [[ $process == "master" ]] && is_pkg_installed "postfix"; then
        if set_keyword_argument_in_file "$POSTFIX_CONFIG" "inet_interfaces" "loopback-only" " = "; then
            systemctl restart postfix
            fixd "Setting postfix interface to loopback-only in $POSTFIX_CONFIG"
        fi
    elif [[ $process == "exim4" ]] && is_pkg_installed "exim4"; then
        if set_keyword_argument_in_file "$EXIM4_CONFIG" "dc_local_interfaces" "'127.0.0.1 ; ::1'" "=" && set_keyword_argument_in_file "$EXIM4_CONFIG" "dc_eximconfig_configtype" "'local'" "="; then
            systemctl restart exim4
            fixd "Setting exim4 interface to loopback in $EXIM4_CONFIG"
        fi
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi