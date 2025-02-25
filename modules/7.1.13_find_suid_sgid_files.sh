#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="7.1.13 - Ensure SUID and SGID files are reviewed"

EXCLUDE_PATHS='/run/user/* /usr/sbin/exim4 /usr/sbin/unix_chkpwd /usr/sbin/mount.nfs /usr/bin/expiry /usr/bin/mount /usr/bin/sudo /usr/bin/chsh /usr/bin/chage /usr/bin/gpasswd /usr/bin/passwd /usr/bin/ssh-agent /usr/bin/chfn /usr/bin/umount /usr/bin/newgrp /usr/bin/dotlockfile /usr/bin/crontab /usr/bin/su /usr/lib/openssh/ssh-keysign /usr/lib/dbus-1.0/dbus-daemon-launch-helper'
EXCLUDE_FSTYPES=''


audit() {
    local exclude_paths="$EXCLUDE_PATHS $(findmnt -Dkerno fstype,target | awk -v fstypes=$(xargs <<< "# $EXCLUDE_FSTYPES" | tr ' ' '|') '$1~"^\s*("fstypes")" {print $2"/*"}' ORS=' ')"
    local exclude_options=()
    local results=()
    while read -r expath; do
        exclude_options+=( -a ! -path "$expath")
    done < <(awk 'BEGIN{RS=" "} NF {print $0}' <<< "$exclude_paths ")
    while IFS= read -r -d $'\0' path; do
        results+=("$(stat -Lc '%n  %#a' "$path")")
    done < <(find / \( "${exclude_options[@]:1}" \) -type f \( -perm -2000 -o -perm -4000 \) -print0 2>/dev/null)
    if [[ ${#results[@]} > 0 ]]; then
        crit "$DESCRIPTION" "${results[@]}"
        return 1
    fi
    pass "$DESCRIPTION"
}


apply() {
    warn "Ensure that no rogue SUID or SGID programs have been introduced into the system"
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi