#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.2.7 - Ensure access to the su command is restricted"

PACKAGE='sudo'
CONF_FILE='/etc/pam.d/su'
SU_PATTERN='^\s*auth\s+(required|requisite)\s+pam_wheel\.so(\s*(#|$)|(\s+(use_uid|group=\S+)){2})'
SU_AFTER_PATTERN='auth +(required|requisite) +pam_wheel\.so *(#|$)'
GROUP='sugroup'
USER_ID='1000'
SU_PARAM="auth       required   pam_wheel.so use_uid group=$GROUP"


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    if ! does_pattern_exist_in_file_nocase "$CONF_FILE" "$SU_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if ! getent group "$GROUP" 2>/dev/null 1>&2; then
        if groupadd -r "$GROUP" 2>/dev/null; then
            local username=$(id -nu "$USER_ID" 2>/dev/null)
            if [[ -n "$username" ]] && usermod -aG "$GROUP" "$username" 2>/dev/null; then
                info_sub "Added group $GROUP with user $username"
                warn "It is recommended to leave this group empty to reinforce the use of sudo for privileged access"
            else
                info_sub "Added group $GROUP"
            fi
        fi
    fi
    if add_line_after_pattern_in_file "$CONF_FILE" "$SU_AFTER_PATTERN" "$SU_PARAM"; then
        fixd "Restricted su usage to group $GROUP in $CONF_FILE"
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
