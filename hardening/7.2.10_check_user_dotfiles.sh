#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.2.10 - Ensure local interactive user dot files access is configured"

PASSWD_FILE='/etc/passwd'
VALID_SHELLS="$(grep -E '^/' /etc/shells | grep -Ev '\bnologin\b' | paste -sd' ')"
DOT_PERMISSIONS=''
DOT_REMOVE=''


check_dotfile_permissions() {
    local dotfile="$1"
    local user="$2"
    local bname=$(basename "$dotfile")
    local group=$(id -gn "$user")
    local options=""
    case "$bname" in
        .forward | .rhost)
            options="664;Y" ;;
        .netrc | .bash_history)
            options="600;" ;;
        *)
            options="644;" ;;
    esac
    DOT_PERMISSIONS=$(echo "$options" | cut -d';' -f 1)
    DOT_REMOVE=$(echo "$options" | cut -d';' -f 2)
    if has_file_less_permissions "$dotfile" "$DOT_PERMISSIONS" && has_file_correct_ownership "$dotfile" "$user" "$group" && [[ -z "$DOT_REMOVE" ]]; then
        return
    fi
    return 1
}

audit() {
    while IFS=: read -r user homedir shell; do
        if ! list_contains "$VALID_SHELLS" "$shell" || ! does_dir_exist "$homedir"; then
            continue
        fi
        for file in $(find $homedir -xdev -type f -name '.*'); do
            if ! check_dotfile_permissions "$file" "$user"; then
                crit "$DESCRIPTION"
                return 1
            fi
        done
    done < <(cut -d: -f1,6,7 "$PASSWD_FILE")
    pass "$DESCRIPTION"
}


apply() {
    while IFS=: read -r user homedir shell; do
        if ! list_contains "$VALID_SHELLS" "$shell" || ! does_dir_exist "$homedir"; then
            continue
        fi
        local group=$(id -gn "$user" 2>/dev/null)
        for file in $(find $homedir -xdev -type f -name '.*'); do
            if ! check_dotfile_permissions "$file" "$user"; then
                if [[ -n "$DOT_REMOVE" ]]; then
                    if delete_file "$file"; then
                        fixd "Removed $file from the system"
                    fi
                    continue
                fi
                if ! has_file_less_permissions "$file" "$DOT_PERMISSIONS"; then
                    if chmod 0"$DOT_PERMISSIONS" "$file"; then
                        fixd "Permissions for $file set to $DOT_PERMISSIONS"
                    fi
                fi
                if ! has_file_correct_ownership "$file" "$user" "$group"; then
                    if chown "$user":"$group" "$file"; then
                        fixd "Ownership for $file set to $user:$group"
                    fi
                fi
            fi
        done
    done < <(cut -d: -f1,6,7 "$PASSWD_FILE")
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi