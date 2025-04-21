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
