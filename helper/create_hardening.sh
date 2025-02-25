#!/bin/bash

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")

OUTPUT_FILE='hardening.sh.tmp'
INPUT_DIR="$SCRIPT_DIR/../modules"

DESC_PATTERN='^\s*DESCRIPTION="([^"]*)"'


out() {
    echo -e "$1" >> "$OUTPUT_FILE"
}

l_scripts=''
while read -r path; do
    desc=$(grep -Em 1 "$DESC_PATTERN" "$path" | sed -rn "s/$DESC_PATTERN/\1/p")
    l_scripts+="    source $(basename $path)        # $desc\n"
done < <(find "$INPUT_DIR" -maxdepth 1 -type f -name '*.sh' ! -name 'common.sh' | sort -V)

scripts=$(echo -e "$l_scripts" | column -s '#' -o '#' -t)


[[ -f "$OUTPUT_FILE" ]] && rm "$OUTPUT_FILE"
out '#!/bin/bash

# Initialize variables
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
SCRIPT_APPLY=false
SCRIPT_FORCE=false

# Function to display help
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -a, --apply       Apply hardening changes to this system."
  echo "  -f, --force       Force changes (ignores SSH warnings)."
  echo "  -h, --help        Show this help message and exit."
  exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--apply)
      SCRIPT_APPLY=true
      shift # Move to the next argument
      ;;
    -f|--force)
      SCRIPT_FORCE=true
      shift # Move to the next argument
      ;;
    -h|--help)
      show_help # Call the help function and exit
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help or -h to see available options."
      exit 1
      ;;
  esac
done

harden_all() {
    cd "$SCRIPT_DIR/modules"'
out "$scripts"
out '}

harden_all'