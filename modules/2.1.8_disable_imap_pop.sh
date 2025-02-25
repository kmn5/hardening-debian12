#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.1.8 - Ensure message access server services are not in use"

PACKAGES='citadel-server courier-imap cyrus-imapd-2.4 dovecot-imapd mailutils-imap4d courier-pop cyrus-pop3d-2.4 dovecot-pop3d heimdal-servers mailutils-pop3d popa3d solid-pop3d xmail'


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
            apt_autoremove
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi