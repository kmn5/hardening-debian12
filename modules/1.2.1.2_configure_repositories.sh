#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="1.2.1.2 - Ensure package manager repositories are configured"


audit() {
    info "$DESCRIPTION"
    apt-cache policy | grep -o "https*://\S* \S*" | sort | awk '{print " ",$0}'
}


apply() {
    :
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi