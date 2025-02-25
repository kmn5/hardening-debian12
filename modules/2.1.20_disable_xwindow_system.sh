#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.1.20 - Ensure X window server services are not in use"

PACKAGES='xserver-xorg-core xserver-xorg-core-dbg xserver-common xserver-xephyr xserver-xfbdev tightvncserver vnc4server fglrx-driver xvfb xserver-xorg-video-nvidia-legacy-173xx xserver-xorg-video-nvidia-legacy-96xx xnest'


audit() {
    for package in $PACKAGES; do
        if is_pkg_installed "$package"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for package in $PACKAGES; do
        if is_pkg_installed "$package"; then
            if apt_purge "$package"; then
                fixd "Purged $package package from the system"
            fi
        fi
        apt_autoremove
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi