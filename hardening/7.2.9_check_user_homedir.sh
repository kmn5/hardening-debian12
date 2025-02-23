#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.9 - Ensure local interactive user home directories are configured"

PASSWD_FILE='/etc/passwd'
VALID_SHELLS="$(grep -E '^/' /etc/shells | grep -Ev '\bnologin\b' | paste -sd' ')"
PERMISSIONS='750'


audit() {
    while IFS=: read -r user homedir shell; do
        if ! list_contains "$VALID_SHELLS" "$shell"; then
            continue
        fi
        if ! does_dir_exist "$homedir"; then
            crit "$DESCRIPTION" 
            return 1
        fi
        if ! has_file_correct_ownership "$homedir" "$user" ""; then
            crit "$DESCRIPTION" 
            return 1
        fi
        if ! has_file_less_permissions "$homedir" "$PERMISSIONS"; then
            crit "$DESCRIPTION" 
            return 1
        fi
    done < <(cut -d: -f1,6,7 "$PASSWD_FILE")
    pass "$DESCRIPTION"
}


apply() {
    while IFS=: read -r user homedir shell; do
        if ! list_contains "$VALID_SHELLS" "$shell"; then
            continue
        fi
        if grep -Eqv '^\/(home\/|root)' <<< "$homedir"; then
            warn "Interactive user $user has a non standard home directory \"$homedir\" specified; skipping modifications"
            continue
        fi
        if ! does_dir_exist "$homedir"; then
            if mkdir -m "$PERMISSIONS" "$homedir" | chown "$user" "$homedir" 2>/dev/null ; then
                fixd "Set home directory of user $user to $homedir"
            fi
            continue
        fi
        if ! has_file_correct_ownership "$homedir" "$user" ""; then
            if chown "$user" "$homedir" 2>/dev/null; then
                fixd "Ownership for $homedir set to $user"
            fi
        fi
        if ! has_file_less_permissions "$homedir" "$PERMISSIONS"; then
            if chmod g-w,o-rwx "$homedir" 2>/dev/null; then
                fixd "Removed excess permissions from $homedir"
            fi
        fi
    done < <(cut -d: -f1,6,7 "$PASSWD_FILE")
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi