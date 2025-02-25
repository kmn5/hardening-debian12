#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.3.2 - Ensure default user shell timeout is configured"

CONF_FIND='/etc/profile.d/*.sh /etc/profile /etc/bashrc'
PATTERN='^\s*([^#]+\s+)?TMOUT=(90[1-9]|9[1-9]\d|\d{4,})'
CONF_FILE='/etc/profile.d/50-default_timeout.sh'
PARAM='TMOUT'
VALUE='900'
SUFFIX_PATTERN='(readonly|export) TMOUT'
SUFFIX=$(echo -e "readonly $PARAM\nexport $PARAM")


audit() {
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$PATTERN"; then
            break
        fi
        if does_pattern_exist_in_file_nocase "$file" "^\s*([^#]+\s+)?$PARAM="; then
            pass "$DESCRIPTION"
            return
        fi 
    done
    crit "$DESCRIPTION"
    return 1
}


apply() {
    if set_keyword_argument_in_file "$CONF_FILE" "$PARAM" "$VALUE" "="; then
        fixd "Parameter $PARAM set to $VALUE in $CONF_FILE"
        if does_pattern_exist_in_file_multiline "$CONF_FILE" "$SUFFIX_PATTERN"; then
            delete_line_in_file "$CONF_FILE" "$SUFFIX_PATTERN"
        fi
        add_end_of_file "$CONF_FILE" "$SUFFIX"
    fi
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$PATTERN"; then
            warn "Manually change the $PARAM in file $file to 900 or less"
            return
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi