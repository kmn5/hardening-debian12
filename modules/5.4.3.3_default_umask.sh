#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="5.4.3.3 - Ensure default user umask is configured"

CONF_FIND='/etc/profile.d/*.sh /etc/profile /etc/bashrc /etc/bash.bashrc'
LOGIN_FIND='/etc/login.defs /etc/default/login'
PATTERN='^\s*([^#]+\s+)?umask\s+([0-7]?[0-7]([01][0-7]|[0-7][0-6])\b|[^ #]*(g=[rx]*w|o=[rwx]))'
CONF_FILE='/etc/profile.d/50-default_umask.sh'
PARAM='umask'
VALUE='0027'


audit() {
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$PATTERN"; then
            break
        fi
        if does_pattern_exist_in_file_nocase "$file" "^\s*([^#]+\s+)?$PARAM\s"; then
            pass "$DESCRIPTION"
            return
        fi 
    done
    crit "$DESCRIPTION"
    return 1
}


apply() {
    if set_keyword_argument_in_file "$CONF_FILE" "$PARAM" "$VALUE"; then
        fixd "Parameter $PARAM set to $VALUE in $CONF_FILE"
    fi
    for file in $LOGIN_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$PATTERN"; then
            if set_keyword_argument_in_file "$file" "${PARAM^^}" "${VALUE^^}"; then
                fixd "Parameter ${PARAM^^} set to $VALUE in $file"
            fi
        fi
    done
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$PATTERN"; then
            warn "Manually change the $PARAM in file $file to 0027 or less permissive"
            return
        fi
    done
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi