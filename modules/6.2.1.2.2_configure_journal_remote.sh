#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.2.1.2.2 - Ensure systemd-journal-remote authentication is configured"

PACKAGE='systemd-journal-remote'
CONF_FILE='/etc/systemd/journal-upload.conf'
PATTERNS='^[[:space:]]*URL= ^[[:space:]]*ServerKeyFile= ^[[:space:]]*ServerCertificateFile= ^[[:space:]]*TrustedCertificateFile='


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for pattern in $PATTERNS; do
        if ! does_pattern_exist_in_file "$CONF_FILE" "$pattern"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    warn "Configure a remote log server in {$CONF_FILE}"
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi