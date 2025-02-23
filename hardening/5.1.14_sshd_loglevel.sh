#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.1.14 - Ensure sshd LogLevel is configured"

PACKAGE='openssh-server'
SERVICE_NAME='sshd'
CONF_FILE='/etc/ssh/sshd_config.d/50-hardening.conf'
SSHD_PATTERN='^loglevel (verbose)$'
SSHD_OPTION='LogLevel=VERBOSE'


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
    local param=$(cut -d= -f 1 <<< "$SSHD_OPTION")
    local value=$(cut -d= -f 2- <<< "$SSHD_OPTION")
    if set_keyword_argument_in_file "$CONF_FILE" "$param" "$value"; then
        fixd "Parameter $param set to $value in $CONF_FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi