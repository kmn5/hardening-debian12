#!/bin/bash

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=1

DESCRIPTION="4.1.4 - Ensure ufw loopback traffic is configured"

PACKAGE='ufw'
UFW_PATTERNS='^Anywhere[[:space:]]on[[:space:]]lo\s+ALLOW[[:space:]]IN\s+Anywhere ^Anywhere\s+DENY[[:space:]]IN\s+127\.0\.0\.0\/8 ^Anywhere\s+ALLOW[[:space:]]OUT\s+Anywhere[[:space:]]on[[:space:]]lo ^Anywhere[[:space:]]\(v6\)[[:space:]]on[[:space:]]lo\s+ALLOW[[:space:]]IN\s+Anywhere[[:space:]]\(v6\) ^Anywhere[[:space:]]\(v6\)\s+DENY[[:space:]]IN\s+::1 ^Anywhere[[:space:]]\(v6\)\s+ALLOW[[:space:]]OUT\s+Anywhere[[:space:]]\(v6\)[[:space:]]on[[:space:]]lo'
UFW_RULES='ufw_allow_in_on_lo ufw_allow_out_on_lo ufw_deny_in_from_127.0.0.0/8 ufw_deny_in_from_::1'


audit() {
    if ! is_pkg_installed "$PACKAGE"; then
        return
    fi
    local ufw_status=$(ufw status verbose)
    if ! echo "$ufw_status" | grep -q "Status: active"; then
        return
    fi
    for pattern in $UFW_PATTERNS; do
        if [[ "$pattern" =~ "\(v6\)" ]] && ! is_ipv6_enabled; then
            continue
        fi
        if ! echo "$ufw_status" | grep -Eq "$pattern"; then
            crit "$DESCRIPTION"
            return 1
        fi
    done
    pass "$DESCRIPTION"
}


apply() {
    for ufw_rule in $UFW_RULES; do
        rule=$(echo "$ufw_rule" | tr _ " ")
        if [[ "$rule" =~ ":" ]] && ! is_ipv6_enabled; then
            continue
        fi
        if $rule 2>/dev/null | grep -q "added"; then
            fixd "Added rule for loopback traffic ($rule)"
        fi
    done
}


# Source root dir parameter
if [[ ! -v SCRIPT_LIB_DIR ]]; then
    SCRIPT_LIB_DIR="$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/../lib"
fi

# Main function, will call proper functions (audit, apply)
if [[ -r "$SCRIPT_LIB_DIR/main.sh" ]]; then
    . "$SCRIPT_LIB_DIR/main.sh"
fi