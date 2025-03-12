#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.2.1.2 - Ensure package manager repositories are configured"


audit() {
    local results=()
    readarray -t results <<< "$(apt-cache policy | grep -o "https*://\S* \S*" | sort)"
    info "$DESCRIPTION" "${results[@]}"
}


apply() {
    :
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi