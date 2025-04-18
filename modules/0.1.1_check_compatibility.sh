#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="0.1.1 - Ensure script is executed on supported environment"

TARGET_DISTRIBUTION='debian'
TARGET_VERSION_ID='12'


audit() {
    if [[ "$(get_distribution)" != "$TARGET_DISTRIBUTION" || "$(get_version_id)" != "$TARGET_VERSION_ID" ]]; then
        crit "$DESCRIPTION" "Running OS: $(get_distribution) $(get_version_id)" "Target OS: $TARGET_DISTRIBUTION $TARGET_VERSION_ID"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    :
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi