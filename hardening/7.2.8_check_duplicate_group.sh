#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.8 - Ensure no duplicate group names exist"

GROUP_FILE='/etc/group'


audit() {
    local results=()
    while read -r group; do
        results+=("$group")
    done < <(cut -d: -f1 "$GROUP_FILE" | sort -n | uniq -d)
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "Duplicate groups: $(tr ' ' ',' <<< "${results[@]}")"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Establish unique names for the user groups; file group ownerships will automatically reflect the change as long as the groups have unique GIDs"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi