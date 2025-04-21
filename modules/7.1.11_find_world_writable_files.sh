#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="7.1.11 - Ensure world writable files and directories are secured"

EXCLUDE_PATHS='/run/user/* /proc/* */containerd/* */kubelet/pods/* /sys/* /snap/*'
EXCLUDE_FSTYPES='nfs proc smb vfat'


audit() {
    local exclude_paths="$EXCLUDE_PATHS $(findmnt -Dkerno fstype,target | awk -v fstypes=$(xargs <<< "# $EXCLUDE_FSTYPES" | tr ' ' '|') '$1~"^\s*("fstypes")" {print $2"/*"}' ORS=' ')"
    local exclude_options=()
    while read -r expath; do
        exclude_options+=( -a ! -path "$expath")
    done < <(awk 'BEGIN{RS=" "} NF {print $0}' <<< "$exclude_paths ")
    while IFS= read -r -d $'\0' path; do
        if does_file_exist "$path"; then
            crit "$DESCRIPTION"
            return 1
        fi
        if [[ -d "$path" ]] && [[ ! $(( "$(stat -Lc '%#a' "$path")" & 01000)) -gt 0 ]]; then
            crit "$DESCRIPTION"
            return 1
        fi
    done < <(find / \( "${exclude_options[@]:1}" \) \( -type f -o -type d \) -perm -0002 -print0 2>/dev/null)
    pass "$DESCRIPTION"
}


apply() {
    local exclude_paths="$EXCLUDE_PATHS $(findmnt -Dkerno fstype,target | awk -v fstypes=$(xargs <<< "$EXCLUDE_FSTYPES" | tr ' ' '|') '$1~"^\s*("fstypes")" {print $2"/*"}' ORS=' ')"
    local exclude_options=()
    while read -r expath; do
        exclude_options+=( -a ! -path "$expath")
    done < <(awk 'BEGIN{RS=" "} NF {print $0}' <<< "$exclude_paths ")
    while IFS= read -r -d $'\0' path; do
        if does_file_exist "$path"; then
            if chmod o-w "$path" 2>/dev/null; then
                fixd "Removed other write permissions from file $path"
            fi
        fi
        if [[ -d "$path" ]] && [[ ! $(( "$(stat -Lc '%#a' "$path")" & 01000)) -gt 0 ]]; then
            if chmod a+t "$path" 2>/dev/null; then
                fixd "Added sticky bit to directory $path"
            fi
        fi
    done < <(find / \( "${exclude_options[@]:1}" \) \( -type f -o -type d \) -perm -0002 -print0 2>/dev/null)
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi