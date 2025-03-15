#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="0.1.1 - Ensure script is executed on supported environment"

TARGET_DISTRIBUTION='debian'
TARGET_VERSION_ID='12'
DISTRIBUTION="$(get_distribution)"
VERSION_ID="$(get_version_id)"


audit() {
    if [[ "$DISTRIBUTION" != "$TARGET_DISTRIBUTION" || "$VERSION_ID" != "$TARGET_VERSION_ID" ]]; then
        crit "$DESCRIPTION" "Running OS: $DISTRIBUTION $VERSION_ID" "Target OS: $TARGET_DISTRIBUTION $TARGET_VERSION_ID"
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