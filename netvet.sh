#!/usr/bin/env bash
# Network Node Mapper
# A pure Bash script to discover live hosts on the local /24 network via ping sweep,
# gather basic details (hostname via reverse DNS, MAC via ip neigh), and display
# them in an interactive dialog menu system.
#
# Requirements:
# - dialog (for the menu UI)
# - Standard utilities: ip, ping, getent, awk, sort
#
# Note: Assumes a /24 subnet (common for home/SOHO networks). If your network uses
# a different prefix (e.g., /23 or /22), the scan will be incomplete or incorrect.
# Runs without root privileges.

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

        # MAC address from neighbor table
        mac=$(ip neigh show dev "$interface" to "$ip" 2>/dev/null | awk '{print toupper($5)}' || echo "unknown")

        item="$(printf "%-15s %-30s %s" "$ip" "$hostname" "$mac")"
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
        --backtitle "Network Mapper – ${#alive_ips[@]} nodes on $subnet.0/24" \
        --title "Discovered Nodes" \
        --cancel-label "Exit" \
        --extra-button --extra-label "Rescan" \
        --menu "Select a node for details (IP            Hostname(s)                    MAC)" \
        0 0 0 \
        "${menu_options[@]}" \
        2>&1 1>&3)
    dlg_status=$?
    exec 3>&-

    case $dlg_status in
        0)  # OK – node selected
            selected_ip="$selection"

            hostname=$(getent hosts "$selected_ip" 2>/dev/null | awk '{print $NF}' | sort -u | paste -sd "," - || echo "unknown")
            mac=$(ip neigh show dev "$interface" to "$selected_ip" 2>/dev/null | awk '{print toupper($5)}' || echo "unknown")
            link_type=$(ip neigh show dev "$interface" to "$selected_ip" 2>/dev/null | awk '{print $6}' || echo "unknown")

            details=$(printf "IP Address:   %s\nHostname(s):  %s\nMAC Address:  %s\nLink Type:    %s" \
                "$selected_ip" "$hostname" "$mac" "$link_type")

            dialog --title "Details – $selected_ip" --msgbox "$details" 12 70
            ;;
        1|255)  # Cancel or ESC
            clear
            exit 0
            ;;
        3)  # Extra button – Rescan
            if dialog --yesno "Rescan the network now?" 6 40; then
                scan_network
                [[ ${#alive_ips[@]} -eq 0 ]] && {
                    dialog --msgbox "No hosts found after rescan." 8 50
                    clear
                    exit 0
                }
            fi
            ;;
    esac
done

