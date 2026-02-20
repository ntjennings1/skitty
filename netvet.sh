#!/usr/bin/env bash

function throw_exec(){
  if [ "$1" = "nv" ]; then
    echo "[ERR] Error running netvet."
  elif [ "$1" = "mac" ]; then
    echo "[ERR] Error finding mac address."
  fi
}

set -euo pipefail
IFS=$'\n\t'

# Check for required dialog utility
if ! command -v dialog >/dev/null 2>&1; then
    echo "Error: 'dialog' is required but not installed." >&2
    echo "Install it via your package manager (e.g., 'sudo apt install dialog' or 'sudo dnf install dialog')." >&2
    exit 1
fi

# Determine primary interface and local subnet (assumes /24)
interface=$(ip -o route get 8.8.8.8 | awk '{print $5; exit}')
local_ip=$(ip -o -4 addr show dev "$interface" scope global | awk '{print $4}' | cut -d'/' -f1)
subnet=${local_ip%.*}

# Arrays to hold discovered data
declare -a alive_ips=()
declare -a menu_options=()

scan_network() {
    local tmp_output
    tmp_output=$(mktemp)

    echo "Scanning $subnet.0/24 (this takes ~2-5 seconds)..."

    # Parallel ping sweep (fully parallel – completes in roughly the timeout duration)
    for oct in {1..254}; do
        ip="$subnet.$oct"
        ( ping -c 1 -W 2 "$ip" >/dev/null 2>&1 && echo "$ip" ) >> "$tmp_output" &
    done
    wait

    # Load and sort discovered IPs
    mapfile -t alive_ips < <(sort -V "$tmp_output")
    rm -f "$tmp_output"

    # Build menu options with details
    menu_options=()
    for ip in "${alive_ips[@]}"; do
        # Reverse hostname lookup (may return multiple aliases)
        hostname=$(getent hosts "$ip" 2>/dev/null | awk '{print $NF}' | sort -u | paste -sd "," - || echo "unknown")

        item="$(printf "%-15s"  "$hostname")"
        menu_options+=("$ip" "$item")
    done
}

# Initial scan
scan_network

if [[ ${#alive_ips[@]} -eq 0 ]]; then
    dialog --msgbox "No live hosts found on $subnet.0/24." 8 50
    clear
    exit 0
fi

# Main interactive loop
while true; do
    # Use file descriptor trick for dialog output
    exec 3>&1
    selection=$(dialog \
        --clear \
        --backtitle "NetVet – ${#alive_ips[@]} nodes on $subnet.0/24" \
        --title "Discovered Nodes" \
        --cancel-label "Exit" \
        --menu "Select a node for details (IP            Hostname(s)                    MAC)" \
        0 0 0 \
        "${menu_options[@]}" \
        2>&1 1>&3)
    dlg_status=$?
    exec 3>&-

    case $dlg_status in
        0)  # OK – node selected
            selected_ip="$selection"

            hostname=$(getent hosts "$selected_ip" 2>/dev/null | awk '{print $NF}' | sort -u | paste -sd "," - || echo "")
            mac=$(sudo nmap "$selected_ip" -sn -T4 | tail -n 2 | head -n 1 | cut -d' ' -f3)
            if [ "${#mac}" = "17" ]; then
              echo "$ip:$mac"
            else
              mac="N/A"
            fi

            details=$(printf "IP Address:   %s\nHostname(s):  %s\nMAC Address:    %s" \
                "$selected_ip" "$hostname" "$mac")

            dialog --title "Details – $selected_ip" --msgbox "$details" 12 70
            ;;
        1|255)  # Cancel or ESC
            clear
            exit 0
            ;;
    esac
done

