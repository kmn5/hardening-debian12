#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="2.1.6 - Ensure ftp server services are not in use"

PACKAGES='ftpd ftpd-ssl heimdal-servers inetutils-ftpd krb5-ftpd muddleftpd proftpd-basic pure-ftpd pure-ftpd-ldap pure-ftpd-mysql pure-ftpd-postgresql twoftpd-run vsftpd wzdftpd'


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