#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.6 - Ensure no duplicate GIDs exist"

GROUP_FILE='/etc/group'


audit() {
    local results=()
    while read -r uid; do
        results+=("$uid")
    done < <(cut -d: -f3 "$GROUP_FILE" | sort -n | uniq -d)
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "Duplicate GIDs: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Establish unique GIDs and review all files owned by the shared GID to determine which group they are supposed to belong to"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi