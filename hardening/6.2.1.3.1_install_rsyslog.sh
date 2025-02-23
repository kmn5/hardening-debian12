#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.1.3.1* - Ensure rsyslog is installed"

PACKAGES='rsyslog'
OTHER_PACKAGES='systemd-journal-remote syslog-ng'


audit() {
    for package in $OTHER_PACKAGES; do
        if is_pkg_installed "$package"; then
            info "$DESCRIPTION"
            warn "Different logging service detected ($package)-> Skipping installation"
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
    if apt_install "$PACKAGES"; then
        fixd "Installed packages: $PACKAGES"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi