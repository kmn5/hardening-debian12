#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="0.2.1 - Ensure script is running with proper umask"

PATTERN='^[0-7]?[0-7]([01][0-7]|[0-7][0-6])$'
UMASK='0027'


audit() {
    if umask | grep -Eq "$PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    if umask "$UMASK" 2>/dev/null 1>&2; then
        fixd "UMASK set to $UMASK for script runtime"
    fi
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi