#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.1.9 - Ensure sshd GSSAPIAuthentication is disabled"

PACKAGE='openssh-server'
SERVICE_NAME='sshd'
CONF_FILE='/etc/ssh/sshd_config.d/50-hardening.conf'
SSHD_OPTION='GSSAPIAuthentication=no'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local param=$(cut -d= -f 1 <<< "$SSHD_OPTION")
    local value=$(cut -d= -f 2- <<< "$SSHD_OPTION")
    if ! sshd -T 2>/dev/null | grep -q "^${param,,} ${value,,}$"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if ss -pntH | grep -q "\"$SERVICE_NAME\"" && ! $SCRIPT_FORCE; then
        return
    fi
    local param=$(cut -d= -f 1 <<< "$SSHD_OPTION")
    local value=$(cut -d= -f 2- <<< "$SSHD_OPTION")
    if set_keyword_argument_in_file "$CONF_FILE" "$param" "$value"; then
        fixd "Parameter $param set to $value in $CONF_FILE"
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