#!/usr/bin/env bash

set -euox pipefail

ALLOWED_NETWORKS=("NW_1" "NW_2")

ssid=$(iwgetid -r)

if [[ -n "$ssid" ]]; then
    for net in "${ALLOWED_NETWORKS[@]}"; do
        if [[ "$ssid" == "$net" ]]; then
            echo "Allowed Wi-Fi Detected: $ssid"
            gsettings set org.gnome.desktop.session idle-delay 0
            exit 0
        fi
    done
fi

gsettings set org.gnome.desktop.session idle-delay 50
echo "Untrusted or no Wi-Fi: ${ssid:-none}"
