#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

. ./common.sh

DESCRIPTION="6.2.2.1 - Ensure access to all logfiles has been configured"

LOG_DIR='/var/log'
LOG_PERMISSIONS=''
LOG_USER=''
LOG_GROUPS=''


check_log_file_permissions() {
    local log_file="$1"
    local bname=$(basename "$log_file")
    local options=""
    case "$bname" in
        lastlog | lastlog.* | wtmp | wtmp.* | wtmp-* | btmp | btmp.* | btmp-* | README)
            options="664;root;root utmp" ;;
        secure | auth.log | syslog | messages)
            options="640;root syslog;root adm" ;;
        SSSD | sssd)
            options="660;root SSSD;root SSSD" ;;
        gdm | gdm3)
            options="660;root;root gdm3" ;;
        *.journal | *.journal~)
            options="640;root;root systemd-journal" ;;
        aide.log | aide.log.* | aideinit.log | aideinit.errors)
            options="640;_aide root;root adm" ;;
        *)
            options="640;root syslog;root adm" ;;
    esac
    if [[ "$log_file" =~ "/exim4/" ]]; then
        options="640;Debian-exim root;root adm"
    fi
    LOG_PERMISSIONS=$(echo "$options" | cut -d';' -f 1)
    LOG_USER=$(echo "$options" | cut -d';' -f 2)
    LOG_GROUPS=$(echo "$options" | cut -d';' -f 3)
    if has_file_less_permissions "$log_file" "$LOG_PERMISSIONS" && has_file_one_of_ownerships "$log_file" "$LOG_USER" "$LOG_GROUPS"; then
        return
    fi
    return 1
}

audit() {
    for file in $(find $LOG_DIR -type f); do
        if ! check_log_file_permissions "$file"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for file in $(find $LOG_DIR -type f); do
        if ! check_log_file_permissions "$file"; then
            if ! has_file_less_permissions "$file" "$LOG_PERMISSIONS"; then
                if chmod 0"$LOG_PERMISSIONS" "$file"; then
                    fixd "Permissions for $file set to $LOG_PERMISSIONS"
                fi
            fi
            if ! has_file_one_of_ownerships "$file" "$LOG_USER" ""; then
                local log_usr=$(echo "$LOG_USER" | cut -d' ' -f 1)
                if chown "$log_usr" "$file"; then
                    fixd "Owner for $file set to $log_usr"
                fi
            fi
            if ! has_file_one_of_ownerships "$file" "" "$LOG_GROUPS"; then
                local log_grp=$(echo "$LOG_GROUPS" | cut -d' ' -f 1)
                if chgrp "$log_grp" "$file"; then
                    fixd "Group for $file set to $log_grp"
                fi
            fi
        fi
    done
}


if ! audit && $SCRIPT_APPLY; then
    apply
fi