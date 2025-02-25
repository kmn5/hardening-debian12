#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="99.1.9.2 - Ensure DNS is configured"

PACKAGE='systemd-resolved'
CONF_FILE='/etc/systemd/resolved.conf'
PATTERN='^\s*(DNS|FallbackDNS)\s*=\s*\S+'
PARAM='DNS'
VALUE='1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com 2606:4700:4700::1111#cloudflare-dns.com 2606:4700:4700::1001#cloudflare-dns.com'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! does_pattern_exist_in_file "$CONF_FILE" "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if set_keyword_argument_in_file "$CONF_FILE" "$PARAM" "$VALUE" "="; then
        fixd "Parameter $PARAM set to $VALUE in $CONF_FILE"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi