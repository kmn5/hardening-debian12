#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.1.2.1 - Ensure systemd-journal-remote is installed"

PACKAGES='systemd-journal-remote'
OTHER_PACKAGES='rsyslog syslog-ng'


audit() {
    for package in $OTHER_PACKAGES; do
        if is_pkg_installed "$package"; then
            info "$DESCRIPTION -> Different logging service installed ($package)"
            return
        fi
    done
    for package in $PACKAGES; do
        if ! is_pkg_installed "$package"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    warn "Preferring rsyslog, so this step will be skipped"
    return
    if apt_install "$PACKAGES"; then
        fixd "Installed packages: $PACKAGES"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi