#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.5 - Ensure no duplicate UIDs exist"

PASSWD_FILE='/etc/passwd'


audit() {
    local results=()
    while read -r uid; do
        results+=("$uid")
    done < <(cut -d: -f3 "$PASSWD_FILE" | sort -n | uniq -d)
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "Duplicate UIDs: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Establish unique UIDs and review all files owned by the shared UIDs to determine which UID they are supposed to belong to"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi