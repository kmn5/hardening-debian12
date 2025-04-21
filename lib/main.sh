#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over


# Initialize variables
SCRIPT_APPLY=false
SCRIPT_FORCE=false
SCRIPT_DOCKER=false
SCRIPT_HARDENING_LEVEL=9


# Import libraries
[[ -r "$SCRIPT_LIB_DIR/common.sh" ]] && . "$SCRIPT_LIB_DIR/common.sh"
[[ -r "$SCRIPT_LIB_DIR/utils.sh" ]] && . "$SCRIPT_LIB_DIR/utils.sh"


# Display help message
show_help() {
    info "Usage: $0 [OPTIONS]"\
        ""\
        "Options:"\
        "  -a,       --apply          Apply hardening changes to this system."\
        "  -f,       --force          Force changes (ignores SSH warnings)."\
        "  -d,       --docker         Skip changes that would break docker service."\
        "  -l <int>, --level=<int>    Set hardening level (1: basic... 5: high security)"\
        "  -h,       --help           Show this help message and exit."
    exit 1
}


# Display unkown option
show_unknown_option() {
    crit "Unknown option: $1"\
        "Use --help or -h to see available options."
    exit 1
}


# Display requires argument
show_requires_argument() {
    crit "Option -$OPTARG requires an argument."\
        "Use --help or -h to see available options."
    exit 1
}


# Parse command-line arguments
while getopts ":afdhl:-:" opt 2>/dev/null; do
    case "$opt" in
        a) SCRIPT_APPLY=true ;;
        f) SCRIPT_FORCE=true ;;
        d) SCRIPT_DOCKER=true ;;
        l) SCRIPT_HARDENING_LEVEL="$OPTARG" ;;
        h) show_help ;;
        -) case "$OPTARG" in  # Long option handler
               apply) SCRIPT_APPLY=true ;;
               force) SCRIPT_FORCE=true ;;
               docker) SCRIPT_DOCKER=true ;;
               level=*) SCRIPT_HARDENING_LEVEL="${OPTARG#*=}" ;;
               help) show_help ;;
               *) show_unknown_option "--$OPTARG" ;;
           esac
           ;;
        :) show_requires_argument "-$OPTARG" ;;
        *) show_unknown_option "$1" ;;
    esac
done
shift "$((OPTIND-1))"  # Remove processed options


# Validate input arguments
if [[ ! "$SCRIPT_HARDENING_LEVEL" =~ ^[0-9]+$ ]]; then
    crit "Input for hardening level is not a positive integer."
    exit 1
fi


# Check for required hardening level
if [[ -v HARDENING_LEVEL ]] && (( $SCRIPT_HARDENING_LEVEL < $HARDENING_LEVEL )) 2>/dev/null; then
    exit 0
fi


# Execute audit and apply functions
if ! audit && $SCRIPT_APPLY; then
    apply
fi