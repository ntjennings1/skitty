#!/bin/bash

function throw_exec(){
  if [ "$1" = "nk" ]; then
    echo "[ERR] Error running NetKno."
  fi
}

function logo(){
cat <<'EOF'

001  00 000000 00000000 00 11 001  00  1001
0001 00 000    00000000 0011  0001 00 0    0
0010100 0000      00    001   0010100 0    0
00 1000 000       00    0011  00 1000 0    0
00  000 000000    00    00 11 00  000  1001

EOF
}

function help(){
  if [ "$1" = "main" ]; then
    logo
    echo
    echo "Welcome to the NetKno network interface analysis tool."
    echo "Any parameters will open this help menu."
    echo "Otherwise, your system's network interfaces will"
    echo "be analyzed."
  fi
}


# Network Information Dialog Script
# Displays current network statistics and characteristics in a formatted dialog box
# Requires: dialog (install with sudo apt install dialog or equivalent)
# Optional: ethtool, iw (for link speed and wireless details), curl (for public IP)
function main(){
  # Temporary file for dialog content
  TEMP_FILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }
  trap 'rm -f "$TEMP_FILE"' EXIT

  logo >> "$TEMP_FILE"

  # Header
  printf "Current Network Statistics and Characteristics\n" >> "$TEMP_FILE"
  printf "==============================================\n" >> "$TEMP_FILE"
  printf "Hostname: %s\n" "$(hostname -f 2>/dev/null || hostname)" >> "$TEMP_FILE"
  printf "Date/Time: %s\n\n" "$(date)" >> "$TEMP_FILE"

  # Find the primary active interface (first UP interface with default route preferred)
  interface=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)
  if [ -z "$interface" ] || ! [ -d "/sys/class/net/$interface" ]; then
    interface=$(ip -br link | awk '$2 == "UP" {print $1; exit}')
  fi
  if [ -z "$interface" ] || ! [ -d "/sys/class/net/$interface" ]; then
    interface=$(ip -br link | awk '{print $1; exit}')
  fi

  if [ -z "$interface" ]; then
    printf "No network interface detected.\n" >> "$TEMP_FILE"
  else
      printf "Primary Interface: %s\n" "$interface" >> "$TEMP_FILE"
      printf "Status: %s\n" "$(cat /sys/class/net/$interface/operstate 2>/dev/null || echo unknown)" >> "$TEMP_FILE"
      printf "MAC Address: %s\n" "$(cat /sys/class/net/$interface/address 2>/dev/null || echo unknown)" >> "$TEMP_FILE"

      # IP addresses
      ipv4=$(ip -4 -o addr show dev "$interface" | awk '{split($4,a,"/"); print a[1]}' | head -n1)
      ipv4_cidr=$(ip -4 -o addr show dev "$interface" | awk '{print $4}' | head -n1)
      printf "IPv4 Address: %s\n" "${ipv4:-none}" >> "$TEMP_FILE"
      [ -n "$ipv4_cidr" ] && printf "IPv4 CIDR: %s\n" "$ipv4_cidr" >> "$TEMP_FILE"

      ipv6=$(ip -6 -o addr show dev "$interface" scope global | awk '{split($4,a,"/"); print a[1]}' | paste -sd ',' -)
      [ -n "$ipv6" ] && printf "IPv6 Address(es): %s\n" "$ipv6" >> "$TEMP_FILE"

      # Gateway
      gateway=$(ip -4 route show default dev "$interface" 2>/dev/null | awk '{print $3}' | head -n1)
      [ -z "$gateway" ] && gateway=$(ip -4 route show default | awk '{print $3}' | head -n1)
      printf "Default Gateway: %s\n" "${gateway:-none}" >> "$TEMP_FILE"

      # DNS
      dns=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | awk '{print $2}' | paste -sd ',' -)
      printf "DNS Servers: %s\n" "${dns:-unknown}" >> "$TEMP_FILE"

      # Link speed (if ethtool available)
      if command -v ethtool >/dev/null 2>&1; then
          speed=$(ethtool "$interface" 2>/dev/null | grep -i 'Speed:' | awk -F ': ' '{print $2}')
          [ -n "$speed" ] && printf "Link Speed: %s\n" "$speed" >> "$TEMP_FILE"
      fi

      # Wireless info (if applicable)
      if command -v iw >/dev/null 2>&1 && iw dev "$interface" info >/dev/null 2>&1; then
          printf "\n--- Wireless Information ---\n" >> "$TEMP_FILE"
          ssid=$(iw dev "$interface" info | grep 'ssid' | awk '{print $2}')
          [ -n "$ssid" ] && printf "SSID: %s\n" "$ssid" >> "$TEMP_FILE"
          signal=$(iw dev "$interface" link 2>/dev/null | grep 'signal:' | awk '{print $2 " " $3}')
          [ -n "$signal" ] && printf "Signal: %s\n" "$signal" >> "$TEMP_FILE"
      fi

      # Interface statistics (human-readable)
      printf "\n--- Interface Statistics ---\n" >> "$TEMP_FILE"
      ip -s -h link show "$interface" >> "$TEMP_FILE" 2>/dev/null || printf "Statistics unavailable\n" >> "$TEMP_FILE"
  fi

  # Public IP (optional, requires internet)
  printf "\n--- External Information ---\n" >> "$TEMP_FILE"
  if command -v curl >/dev/null 2>&1; then
    public_ip=$(curl -s --max-time 8 https://api.ipify.org)
    if [ -n "$public_ip" ]; then
      printf "Public IPv4: %s\n" "$public_ip" >> "$TEMP_FILE"
    else
      printf "Public IPv4: unable to retrieve\n" >> "$TEMP_FILE"
    fi
  else
    printf "Public IPv4: curl not available\n" >> "$TEMP_FILE"
  fi

  # Display dialog (0 0 = auto-size)
  if command -v dialog >/dev/null 2>&1; then
    dialog --keep-tite --title "Network Statistics and Characteristics" --textbox "$TEMP_FILE" 0 0
  else
    echo "dialog not found. Displaying in terminal:"
    cat "$TEMP_FILE"
  fi
}

main "$1"
