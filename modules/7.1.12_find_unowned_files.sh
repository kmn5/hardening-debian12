#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="7.1.12 - Ensure no files or directories without an owner and a group exist"

EXCLUDE_PATHS='/run/user/* /proc/* */containerd/* */kubelet/pods/* /sys/* /snap/*'
EXCLUDE_FSTYPES='nfs proc smb vfat'


audit() {
    local exclude_paths="$EXCLUDE_PATHS $(findmnt -Dkerno fstype,target | awk -v fstypes=$(xargs <<< "# $EXCLUDE_FSTYPES" | tr ' ' '|') '$1~"^\s*("fstypes")" {print $2"/*"}' ORS=' ')"
    local exclude_options=()
    local results=()
    while read -r expath; do
        exclude_options+=( -a ! -path "$expath")
    done < <(awk 'BEGIN{RS=" "} NF {print $0}' <<< "$exclude_paths ")
    while IFS= read -r -d $'\0' path; do
        results+=("$(stat -Lc '%n  %U:%G' "$path")")
    done < <(find / \( "${exclude_options[@]:1}" \) \( -type f -o -type d \) \( -nouser -o -nogroup \) -print0 2>/dev/null)
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "${results[@]}"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Remove or set ownership of these files or directories to an active user on the system as appropriate"
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi