#!/bin/bash

# Author: St3amPunk
# Refactored by Clumsy for advanced CTF pwn environments

set -euo pipefail
shopt -s nullglob

# Function: Requires root privilege
require_root() {
  if [[ "$EUID" -ne 0 ]]; then
    echo -e "\n[!] This script must be run as root.\n"
    exit 1
  fi
}

# Function: Print a header
print_header() {
  clear
  echo -e "╔══════════════════════════════════════╗"
  echo -e "║     🛠  Wireless Interface Utility   ║"
  echo -e "║        Author: St3amPunk             ║"
  echo -e "╚══════════════════════════════════════╝\n"
}

# Function: Fetch available wireless interfaces
get_wireless_interfaces() {
  iw dev | awk '$1 == "Interface" { print $2 }'
}

# Function: Enable monitor mode
enable_monitor_mode() {
  echo "[+] Enabling monitor mode on $1"
  systemctl stop NetworkManager || true
  ip link set "$1" down
  iw "$1" set monitor control
  ip link set "$1" up
  echo "[✓] Monitor mode enabled."
  sleep 1
  iwconfig "$1"
}

# Function: Disable monitor mode
disable_monitor_mode() {
  echo "[+] Disabling monitor mode on $1"
  ip link set "$1" down
  iw "$1" set type managed
  ip link set "$1" up
  systemctl start NetworkManager || true
  echo "[✓] Monitor mode disabled."
  sleep 1
  iwconfig "$1"
}

# Main Execution Flow
require_root
print_header

interfaces=($(get_wireless_interfaces))

if [[ ${#interfaces[@]} -eq 0 ]]; then
  echo "[!] No wireless interfaces found."
  exit 1
fi

echo "Available interfaces:"
for i in "${!interfaces[@]}"; do
  printf "  [%d] %s\n" "$((i + 1))" "${interfaces[$i]}"
done

read -rp $'\nSelect interface number: ' iface_choice
iface_index=$((iface_choice - 1))
selected_iface="${interfaces[$iface_index]:-}"

if [[ -z "$selected_iface" ]]; then
  echo "[!] Invalid selection."
  exit 1
fi

echo -e "\nMode Options:"
echo "  [1] Enable monitor mode"
echo "  [2] Disable monitor mode"
read -rp "Choose an action (1/2): " action

case "$action" in
  1) enable_monitor_mode "$selected_iface" ;;
  2) disable_monitor_mode "$selected_iface" ;;
  *) echo "[!] Invalid option."; exit 1 ;;
esac
