#!/bin/bash

#
# Constants
#

BLDRED="\033[1;31m" # Bold Red
BLDGRN="\033[1;32m" # Bold Green
BLDBLU="\033[1;34m" # Bold Blue
BLDYLW="\033[1;33m" # Bold Yellow
TXTRST="\033[0m"

BACKUPDIR="$HOME/tmp/backups"
SYSCTL_DIRECTORY='/etc/sysctl.d/'
SYSCTL_DEFAULT_FILE='50-hardening.conf'


#
# Logging functions
#

print_formatted_log() {
    local PREFIX="$1"
    local FIRST_LINE="$2"
    printf '%b\n' "${PREFIX}${FIRST_LINE}"
    if [ $# -ge 3 ]; then # more than one line
        local SPACES=$(printf '%b' "$PREFIX" | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | tr '[:print:]' ' ')
        printf "$SPACES%b\n" "${@:3}"
    fi
}

log() {
    print_formatted_log "" "$@"
}

info() {
    print_formatted_log "${BLDBLU}[INFO]${TXTRST} " "$@"
}

pass() {
    print_formatted_log "${BLDGRN}[PASS]${TXTRST} " "$@"
}

crit() {
    print_formatted_log "${BLDRED}[CRIT]${TXTRST} " "$@"
}

warn() {
    print_formatted_log "${BLDYLW}  -> [WARN]${TXTRST} " "$@"
}

fixd() {
    print_formatted_log "${BLDGRN}  -> [FIXED]${TXTRST} " "$@"
}

info_sub() {
    print_formatted_log "${BLDBLU}  -> [INFO]${TXTRST} " "$@"
}

#
# File Backup
#

backup_file() {
    local FILE="$1"
    if ! [[ -f "$FILE" ]]; then
        return # Is not a file
    else
        local TARGET=$(printf '%s' "$FILE" | sed -s -e 's/\//./g' -e 's/^\.//' -e "s/$/.$(date +%FT%H-%M-%S.%3N)/")
        mkdir -pm 700 -- "$BACKUPDIR"
        TARGET="$BACKUPDIR/$TARGET"
        cp -a -- "$FILE" "$TARGET"
    fi
}

#
# File
#

does_file_exist() {
    local FILE="$1"
    if ! [[ -f "$FILE" ]]; then
        return 1 # File does not exist
    fi
}

does_dir_exist() {
    local DIR="$1"
    if ! [[ -d "$DIR" ]]; then
        return 1 # Directory does not exist
    fi
}

has_file_correct_ownership() {
    local FILE="$1"
    local USER="$2"
    local GROUP="$3"
    [[ ! -e $FILE ]] && return
    [[ $USER ]] && USER=$(id -u -- "$USER")
    [[ $GROUP ]] && GROUP=$(getent group -- "$GROUP" | cut -d: -f3)
    if [[ $USER && "$(stat -c '%u' -- "$FILE")" != "$USER" ]]; then
        return 1 # File ownership does not match user
    elif [[ $GROUP && "$(stat -c '%g' -- "$FILE")" != "$GROUP" ]]; then
        return 1 # File ownership does not match user
    fi
}

has_file_one_of_ownerships() {
    local FILE="$1"
    local USERS_OK="$2"
    local GROUPS_OK="$3"
    [[ ! -e $FILE ]] && return
    local perms_res=0
    if [[ $USERS_OK ]]; then
        for user in $USERS_OK; do
            local userid=$(id -u -- "$user" 2>/dev/null)
            [[ $userid ]] || continue
            if [[ "$(stat -c '%u' -- "$FILE")" = "$userid" ]]; then
                ((perms_res++))
            fi
        done
    else ((perms_res++))
    fi
    if [[ $GROUPS_OK ]]; then
        for group in $GROUPS_OK; do
            local groupid=$(getent group -- "$group" 2>/dev/null | cut -d: -f3)
            [[ $groupid ]] || continue
            if [[ "$(stat -c '%g' -- "$FILE")" = "$groupid" ]]; then
                ((perms_res++))
            fi
        done
    else ((perms_res++))
    fi
    if [[ "$perms_res" -lt 2 ]]; then
        return 1
    fi
}

has_file_correct_permissions() {
    local FILE="$1"
    local PERMISSIONS="$2"
    [[ ! -e $FILE ]] && return
    if [[ "$(stat -L -c '%a' -- "$FILE")" != "$PERMISSIONS" ]]; then
        return 1 # File permissions does not match
    fi
}

has_file_one_of_permissions() {
    local FILE="$1"
    local PERMISSIONS="$2"
    [[ ! -e $FILE ]] && return
    for PERMISSION in $PERMISSIONS; do
        if [ "$(stat -L -c '%a' -- "$FILE")" = "$PERMISSION" ]; then
            return
        fi
    done
    return 1 # File permissions does not match any specified
}

has_file_less_permissions() {
    local FILE="$1"
    local PERMISSIONS="$2"
    [[ ! -e $FILE ]] && return
    local file_permissions=$(stat -L -c '%a' -- "$FILE")
    for i in {0..2}; do
        if [[ ${file_permissions:$i:1} -gt ${PERMISSIONS:$i:1} ]]; then
            return 1 # File is more permissive than specified
        fi
    done
}

does_pattern_exist_in_file_multiline() {
    print=$(_does_pattern_exist_in_file "-Ezo" $(sed 's@\$@\[\$\]@g' <<< "$@"))
}

does_pattern_exist_in_file() {
    print=$(_does_pattern_exist_in_file "-E" $(sed 's@\$@\[\$\]@g' <<< "$@"))
}

does_pattern_exist_in_file_nocase() {
    print=$(_does_pattern_exist_in_file "-Ei" $(sed 's@\$@\[\$\]@g' <<< "$@"))
}

_does_pattern_exist_in_file() {
    local OPTIONS="$1"
    shift
    local FILE="$1"
    shift
    local PATTERN="$*"

    if ! [[ -f "$FILE" && -r "$FILE" ]]; then
        return 1 # File is not readable
    fi
    if ! grep -q "$OPTIONS" -- "$PATTERN" "$FILE"; then
        return 1 # Pattern not found in file
    fi
}

delete_file() {
    local FILE="$1"
    backup_file "$FILE"
    rm -- "$FILE"
}

create_temp_file() {
    local file=$(mktemp)
    if [[ $# -ge 1 && -f "$1" ]]; then
        local source_perms=$(stat -c '%a' "$1")
        chmod "$source_perms" "$file" 2>/dev/null
    fi
    printf '%s' "$file"
}

add_end_of_file() {
    local FILE="$1"
    local LINE="$2"
    backup_file "$FILE"
    printf '%s\n' "$LINE" >> "$FILE"
}

write_to_file() {
    local FILE="$1"
    local LINE="$2"
    backup_file "$FILE"
    printf '%s\n' "$LINE" > "$FILE"
}

replace_in_file() {
    local FILE="$1"
    local SOURCE="$2"
    local DESTINATION=$3
    backup_file "$FILE"
    SOURCE=$(sed 's@/@\\\/@g' <<< "$SOURCE")
    sed -Ei -- "s/$SOURCE/$DESTINATION/g" "$FILE"
}

delete_line_in_file() {
    local FILE="$1"
    local PATTERN="$2"
    backup_file "$FILE"
    PATTERN=$(sed 's@/@\\\/@g' <<<"$PATTERN")
    sed -Ei -- "/$PATTERN/d" "$FILE"
}

add_line_after_pattern_in_file() {
    local FILE="$1"
    local PATTERN="$2"
    local LINE="$3"
    backup_file "$FILE"
    touch -- "$FILE"
    local temp_file=$(create_temp_file "$FILE")
    awk -v pattern="$PATTERN" -v line="$LINE" -- '{
        print $0
        if($0~pattern) {
          if(foundLine!=1) print line
          foundLine=1
        }
      } END {
        if(foundLine!=1) print line
      }' "$FILE" > "$temp_file" && mv -- "$temp_file" "$FILE"
}

comment_out_pattern_in_file() {
    local FILE="$1"
    local PATTERN="$2"
    backup_file "$FILE"
    touch -- "$FILE"
    local temp_file=$(create_temp_file "$FILE")
    awk -v pattern="$PATTERN" -- '{
        if($0~pattern) {
          print "#"$0
        } else {
          print $0
        }
      }' "$FILE" > "$temp_file" && mv -- "$temp_file" "$FILE"
}

comment_replace_pattern_in_file() {
    local FILE="$1"
    local PATTERN="$2"
    local LINE="$3"
    backup_file "$FILE"
    touch -- "$FILE"
    local temp_file=$(create_temp_file "$FILE")
    awk -v pattern="$PATTERN" -v line="$LINE" -- '{
        if($0~pattern) {
          print "#"$0
          if(foundLine!=1) print line
          foundLine=1
        } else {
          print $0
        }
      } END {
        if(foundLine!=1) print line
      }' "$FILE" > "$temp_file" && mv -- "$temp_file" "$FILE"
}

set_keyword_argument_in_file() {
    local FILE="$1"
    local KEYWORD="$2"
    local ARGUMENT="$3"
    local SEPERATOR=" "
    local FIELD_SEP=" "

    if [ $# -ge 4 ]; then
        SEPERATOR="$4"
        FIELD_SEP=$(printf '%s' "$4" | xargs)
    fi

    if does_dir_exist "$FILE"; then
        return 1 # is directory
    fi
    backup_file "$FILE"
    touch -- "$FILE"
    local temp_file=$(create_temp_file "$FILE")
    local escaped_keyword=$(sed 's@[]\/$*.^[]@\\&@g' <<< "$KEYWORD")
    awk -F "$FIELD_SEP" -v eskey="$escaped_keyword" -v key="$KEYWORD" -v arg="$ARGUMENT" -v sep="$SEPERATOR" -- '{
        if(tolower($1)~"^ *"tolower(eskey)" *$") {
          if (foundLine!=1) print key""sep""arg;
          foundLine=1;
        } else if(tolower($1)~"^# *"tolower(eskey)" *$" && foundLine!=1) {
          print key""sep""arg;
          foundLine=1;
        } else if($1=="#" && tolower($2)==tolower(eskey) && (!$4 || $4~"^#") && foundLine!=1) {
          print key""sep""arg;
          foundLine=1;
        } else {
          print $0;
        }
      } END {
        if(foundLine!=1) print key""sep""arg
      }' "$FILE" > "$temp_file" && mv -- "$temp_file" "$FILE"

      # line 8 # } else if($1=="#" && tolower($2)==tolower(eskey) && foundLine!=1) {
}

#
# Sysctl
#

has_sysctl_param_expected_result() {
    local SYSCTL_PARAM="$1"
    local EXP_RESULT="$2"
    if [ "$(sysctl -- "$SYSCTL_PARAM" 2>/dev/null)" = "$SYSCTL_PARAM = $EXP_RESULT" ]; then
        return
    else
        return 1
    fi
}

does_sysctl_param_exists() {
    local SYSCTL_PARAM="$1"
    if [ "$(sysctl -a 2>/dev/null | grep -c -- "$SYSCTL_PARAM")" = 0 ]; then
        return 1 # parameter does not exist
    fi
}

set_sysctl_param() {
    local SYSCTL_PARAM="$1"
    local SYSCTL_VALUE="$2"
    local FILE="$SYSCTL_DEFAULT_FILE"

    if [ $# -ge 3 ]; then
        FILE="$3"
    fi

    if ! does_sysctl_param_exists "$SYSCTL_PARAM"; then
        return 1 # parameter does not exist
    fi
    if has_sysctl_param_expected_result "$SYSCTL_PARAM" "$SYSCTL_VALUE"; then
        return 1 # parameter already set correctly
    fi
    if [ -n "$FILE" ]; then
        set_keyword_argument_in_file "${SYSCTL_DIRECTORY}${FILE}" "$SYSCTL_PARAM" "$SYSCTL_VALUE" " = "
    fi
    if [ "$(sysctl -w -- "$SYSCTL_PARAM"="$SYSCTL_VALUE" 2>/dev/null)" = "$SYSCTL_PARAM = $SYSCTL_VALUE" ]; then
        return
    elif has_sysctl_param_expected_result "kernel.modules_disabled" "1"; then
        return # restart required
    else
        return 1 # set parameter failed
    fi
}

#
# Sudo
#

comment_out_sudo_pattern() {
    local FILE="$1"
    local PATTERN="$2"
    backup_file "$FILE"
    touch -- "$FILE"
    local temp_file=$(create_temp_file "$FILE")
    awk -v pattern="$PATTERN" -- '{
        if($0~pattern) {
          print "#"$0
        } else {
          print $0
        }
      }' "$FILE" > "$temp_file"
    if visudo -qcf "$temp_file" 2>/dev/null && mv -- "$temp_file" "$FILE"; then
        return
    fi
    rm -- "$temp_file"
    return 1
}

set_sudo_default_param() {
    local FILE="$1"
    local PARAM="$2"
    backup_file "$FILE"
    local temp_file=$(create_temp_file)

    if ! cp -p -- "$FILE" "$temp_file" 2>/dev/null; then
        return 1
    fi

    if [[ "$PARAM" =~ "=" ]]; then
        local KEYWORD=$(cut -d= -f 1 <<< "$PARAM")
        local ARGUMENT=$(cut -d= -f 2- <<< "$PARAM")
        local escaped_keyword=$(sed 's@[]\/$*.^[]@\\&@g' <<< "$KEYWORD")
        local escaped_argument=$(sed 's@[]\/$*.^[]@\\&@g' <<< "$ARGUMENT")
        sed -i -e "s/\(^\s*Defaults\(\s*\|[^#],\s*\)$escaped_keyword\s*=\s*\)\([^,]*\)/\1$escaped_argument/" "$temp_file"
    fi
    if cmp -s -- "$FILE" "$temp_file"; then
        local escaped_option=$(sed 's@[]\/$*.^[]@\\&@g' <<< "Defaults        $PARAM")
        sed -i -e "0,/^$/s//$escaped_option\n/" "$temp_file"
    fi
    if visudo -qcf "$temp_file" 2>/dev/null && mv -- "$temp_file" "$FILE"; then
        return
    fi
    rm -- "$temp_file"
    return 1
}

#
# IPV6
#

is_ipv6_enabled() {
    local SYSCTL_PARAMS="net.ipv6.conf.all.disable_ipv6=1 net.ipv6.conf.default.disable_ipv6=1 net.ipv6.conf.lo.disable_ipv6=1"

    if ! does_sysctl_param_exists "net.ipv6"; then
        return 1 # ipv6 not enabled
    fi
    for sysctl_values in $SYSCTL_PARAMS; do
        local SYSCTL_PARAM=$(printf '%s' "$sysctl_values" | cut -d= -f 1)
        local SYSCTL_EXP_RESULT=$(printf '%s' "$sysctl_values" | cut -d= -f 2)
        if ! has_sysctl_param_expected_result "$SYSCTL_PARAM" "$SYSCTL_EXP_RESULT"; then
            return # parameter to disable ipv6 not set
        fi
    done
    return 1
}

#
# Users and groups
#

does_user_exist() {
    local USER="$1"
    if ! getent passwd -- "$USER" >/dev/null 2>&1; then
        return 1 # User does not exist
    fi
}

does_group_exist() {
    local GROUP="$1"
    if ! getent group -- "$GROUP" >/dev/null 2>&1; then
        return 1 # Groups does not exist
    fi
}

is_process_running_as_user() {
    local PROCESS="$1"
    local USER="$2"
    if [[ "$(ps -ef | grep -- '\W'$PROCESS'\W' | grep -v -- '^'$USER'\W' | wc -l)" -gt 0  ]]; then
        return 1 # Process not running as user
    fi
}

#
# Service Checks
#

is_service_enabled() {
    local SERVICE="$1"
    if [[ $(systemctl is-enabled -- "$SERVICE" 2>/dev/null) != "enabled" ]]; then
        return 1 # Service is disabled
    fi
}

is_service_static() {
    local SERVICE="$1"
    if [[ $(systemctl is-enabled -- "$SERVICE" 2>/dev/null) != "static" ]]; then
        return 1 # Service is not static
    fi
}

is_service_active() {
    local SERVICE="$1"
    if [[ $(systemctl is-active -- "$SERVICE" 2>/dev/null) != "active" ]]; then
        return 1 # Service is inactive
    fi
}

#
# Kernel options checks
#

is_kernel_module_enabled() {
    local MODULE_NAME="$1"
    local MODPROBE_FILTER=""
    local DEF_MODULE=""

    if [ $# -ge 2 ]; then
        MODPROBE_FILTER="$2"
    fi

    if ! lsmod >/dev/null 2>&1; then
        return 127 # Monolithic kernel
    fi

    if [[ "$MODPROBE_FILTER" != "" ]]; then
        DEF_MODULE="$(modprobe -n -v -- "$MODULE_NAME" 2>/dev/null | grep -E -- "$MODPROBE_FILTER" | tail -1 | xargs)"
    else
        DEF_MODULE="$(modprobe -n -v -- "$MODULE_NAME" 2>/dev/null | tail -1 | xargs)"
    fi

    if [[ "$DEF_MODULE" == "install /bin/true" ]] || [[ "$DEF_MODULE" == "install /bin/false" ]]; then
        return 1 # Module is disabled (blacklist with override)
    elif [ "$DEF_MODULE" == "" ]; then
        return 1 # Module is disabled
    fi
}

#
# Mounting point
#

is_a_partition() {
    local PARTITION="$1"
    if grep -- "[[:space:]]$1[[:space:]]" /etc/fstab | grep -vqE "^#"; then
        return # Partition found in fstab
    elif mountpoint -q -- "$PARTITION"; then
        return # Partition found in /proc/fs
    else
        return 1 # Unable to find partition in fstab
    fi
    return 128
}

is_mounted() {
    local PARTITION="$1"
    if ! grep -q -- "[[:space:]]$1[[:space:]]" /proc/mounts; then
        return # Unable to find partition in /proc/mounts
    fi
}

has_mount_option() {
    local PARTITION="$1"
    local OPTION="$2"
    if grep -- "[[:space:]]${PARTITION}[[:space:]]" /etc/fstab | grep -vE "^#" | awk '{print $4}' | grep -q "bind"; then
        PARTITION="$(grep "[[:space:]]${PARTITION}[[:space:]]" /etc/fstab | grep -vE "^#" | awk '{print $1}')" # Partition is a bind mount
    fi
    if grep -- "[[:space:]]${PARTITION}[[:space:]]" /etc/fstab | grep -vE "^#" | awk '{print $4}' | grep -q -- "$OPTION"; then
        return # Option has been detected in fstab for partition
    elif mountpoint -q -- "$PARTITION" && grep -- "[[:space:]]$1[[:space:]]" /proc/mounts | awk '{print $4}' | grep -q -- "$2"; then
        return # Option has been detected in /proc/mounts for partition
    fi
    return 1
}

add_option_to_fstab() {
    local PARTITION="$1"
    local OPTION="$2"
    backup_file "/etc/fstab"
    sed -i -e "s;\(.*\)\(\s*\)\s\($PARTITION\)\s\(\s*\)\(\w*\)\(\s*\)\(\w*\)*;\1\2 \3 \4\5\6\7,$OPTION;" /etc/fstab
    if ! has_mount_option "$PARTITION" "$OPTION"; then
        return 1
    fi
}

#
# APT
#

apt_update_if_needed() {
    if [ -e /var/cache/apt/pkgcache.bin ]; then
        UPDATE_AGE=$(($(date +%s) - $(stat -c '%Y' /var/cache/apt/pkgcache.bin)))

        if [ "$UPDATE_AGE" -gt 21600 ]; then
            # Last update older than 6 hours, refresh database
            apt-get update -y >/dev/null 2>/dev/null
        fi
    else
        apt-get update -y >/dev/null 2>/dev/null
    fi
}

apt_check_upgrades() {
    if [[ $(apt-get upgrade -s 2>/dev/null | grep -E "^Inst" | wc -l) -gt 0 ]]; then
        return 1 # Upgrades available
    fi
}

apt_install() {
    local PACKAGE="$1"
    DEBIAN_FRONTEND='noninteractive' APT_LISTBUGS_FRONTEND='none' apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y install -- $PACKAGE 2>/dev/null 1>&2
}

apt_purge() {
    local PACKAGE="$1"
    DEBIAN_FRONTEND='noninteractive' apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y purge -- $PACKAGE 2>/dev/null 1>&2
}

apt_autoremove() {
    DEBIAN_FRONTEND='noninteractive' apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y autoremove 2>/dev/null 1>&2
}

apt_check_dependencies() {
    local PACKAGE="$1"
    if [[ $(apt-cache rdepends --installed -- "$PACKAGE" | tail -n +3) ]]; then
        return 1 # Dependencies detected
    fi
}

is_version_greater() {
    local REQUIRED_VER="$1"
    local CURRENT_VER="$2"
    if [[ "$(printf '%s\n' "$REQUIRED_VER" "$CURRENT_VER" | sort -V | head -n1)" != "$REQUIRED_VER" ]]; then
        return 1 # Current version less than required version
    fi
}

is_pkg_installed() {
    local PACKAGE="$1"
    if ! dpkg -s -- "$PACKAGE" 2>/dev/null | grep -q '^Status: install '; then
        return 1 # Package is not installed
    fi
}

is_pkg_up_to_date() {
    local PACKAGE="$1"
    local REQUIRED_VER="$2"
    local current_version=$(dpkg -s -- "$PACKAGE" 2>/dev/null | grep -oP "^Version:\s*\K\S+")
    if [[ -n "$current_version" ]] && is_version_greater "$REQUIRED_VER" "$current_version"; then
        return # Package has required version
    fi
    return 1
}

#
# OS
#

get_distribution() {
    DISTRIBUTION=''
    local OSFILE='/etc/os-release'
    if ! [[ -f "$OSFILE" ]]; then
        return 1 # File does not exist
    fi
    DISTRIBUTION=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr '[:upper:]' '[:lower:]' | sed -e 's/"//g')
}

#
# Misc
#

list_contains() {
    local LIST="$1"
    local ITEM="$2"
    if ! grep -wq -- "$ITEM" <<< "$LIST"; then
        return 1 # List does not contain item
    fi
}