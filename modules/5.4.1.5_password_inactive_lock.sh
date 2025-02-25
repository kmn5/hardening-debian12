#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="5.4.1.5 - Ensure inactive password lock is configured"

SHADOW_FILE='/etc/shadow'
NUMBER_PATTERN='([0-9]|[1-3][0-9]|4[0-5])'
USERADD_PATTERN="^INACTIVE=$NUMBER_PATTERN$"
SHADOW_AWK='($2~/^\$.+\$/) {if($7 > 45 || $7 < 0) print $1}'
USERADD_OPTION='f=45'
CHAGE_PARAM='inactive'


audit() {
    if ! useradd -D 2>/dev/null | grep -Eiq "$USERADD_PATTERN"; then
        crit "$DESCRIPTION"
        return 1
    fi
    if [[ $(awk -F: "$SHADOW_AWK" "$SHADOW_FILE" 2>/dev/null) ]]; then
        crit "$DESCRIPTION"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    local param=$(cut -d= -f 1 <<< "$USERADD_OPTION")
    local value=$(cut -d= -f 2- <<< "$USERADD_OPTION")
    if ! useradd -D 2>/dev/null | grep -Eiq "$USERADD_PATTERN"; then
        if useradd -D -"$param" "$value" 2>/dev/null 1>&2; then
            fixd "Useradd -$param set to $value"
        fi
    fi
    while read -r user; do
        if chage --"$CHAGE_PARAM" "$value" "$user" 2>/dev/null; then
            fixd "Parameter $CHAGE_PARAM set to $value for $user"
        fi
    done < <(awk -F: "$SHADOW_AWK" "$SHADOW_FILE" 2>/dev/null)
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi