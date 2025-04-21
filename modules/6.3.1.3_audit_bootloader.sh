#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="6.3.1.3 - Ensure auditing for processes that start prior to auditd is enabled"

PACKAGE='auditd'
GRUB_FILE='/etc/default/grub'
GRUB_OPTIONS='GRUB_CMDLINE_LINUX=audit=1'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    for option in $GRUB_OPTIONS; do
        grub_param=$(echo "$option" | cut -d= -f 1)
        grub_value=$(echo "$option" | cut -d= -f 2-)
        pattern="^$grub_param=.*$grub_value"
        if ! does_pattern_exist_in_file "$GRUB_FILE" "$pattern"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for option in $GRUB_OPTIONS; do
        grub_param=$(echo "$option" | cut -d= -f 1)
        grub_value=$(echo "$option" | cut -d= -f 2-)
        new_value="$grub_value"
        if does_pattern_exist_in_file "$GRUB_FILE" "^$grub_param="; then
            local old_value=$(cat "$GRUB_FILE" | grep -E "^$grub_param=" | perl -lne 'print "$1" if /^\w+=["]?([^"]*)["]?$/')
            new_value="$(echo $old_value $grub_value)"
        fi
        if set_keyword_argument_in_file "$GRUB_FILE" "$grub_param" "\"$new_value\"" "="; then
            update-grub 2>/dev/null
            fixd "Parameter $grub_param set to $grub_value in $GRUB_FILE"
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