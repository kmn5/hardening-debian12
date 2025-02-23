#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.2.6 - Ensure root user umask is configured"

CONF_FIND='/root/.bash_profile /root/.bashrc'
PATTERN='^ *umask +([0-7]?[0-7]([01][0-7]|[0-7][0-6]) *$|[^ #]*(g=[rx]*w|o=[rwx]))'


audit() {
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file_nocase "$file" "$PATTERN"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $CONF_FIND; do
        if does_pattern_exist_in_file "$file" "$PATTERN"; then
            if comment_out_pattern_in_file "$file" "$PATTERN"; then
                fixd "Removed permissive umask value from $file"
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi