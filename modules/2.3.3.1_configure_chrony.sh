#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.3.3.1 - Ensure chrony is configured with authorized timeserver"

PACKAGE='chrony'
CONF_DEFAULT_PATTERN='^(server|pool)'
CONF_FILE='/etc/chrony/chrony.conf'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! does_pattern_exist_in_file "$CONF_FILE" "$CONF_DEFAULT_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Manually configure chrony yourself"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi