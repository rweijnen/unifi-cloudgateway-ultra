#!/bin/bash

LOGFILE="/var/log/setmtu.log"
INTERFACES_FILE="/tmp/interfaces.json"
TEMP_FILE="/tmp/interfaces.tmp"
MODIFIED=false

ubios-udapi-client -r GET /interfaces > "$INTERFACES_FILE"

# Log function
log() {
    echo "$(date): $1" >> "$LOGFILE"
}

# Modify MTU for eth4
log "Checking current MTU for eth4"
MTU_ETH4=$(jq '.[] | select(.identification.id == "eth4") | .status.mtu' "$INTERFACES_FILE")
if [[ "$MTU_ETH4" -ne 1512 ]]; then
    jq 'map(if .identification.id == "eth4" then .status.mtu = 1512 else . end)' "$INTERFACES_FILE" > "$TEMP_FILE" && mv -f "$TEMP_FILE" "$INTERFACES_FILE"
    log "Changed MTU for eth4 to 1512"
    MODIFIED=true
fi

# Modify MTU for eth4.6
log "Checking current MTU for eth4.6"
MTU_ETH4_6=$(jq '.[] | select(.identification.id == "eth4.6") | .status.mtu' "$INTERFACES_FILE")
if [[ "$MTU_ETH4_6" -ne 1508 ]]; then
    jq 'map(if .identification.id == "eth4.6" then .status.mtu = 1508 else . end)' "$INTERFACES_FILE" > "$TEMP_FILE" && mv -f "$TEMP_FILE" "$INTERFACES_FILE"
    log "Changed MTU for eth4.6 to 1508"
    MODIFIED=true
fi

log "Checking current MRU, MTU, and current MTU for pppoe (ppp0)"
MRU_PPP0=$(jq '.[] | select(.identification.id == "ppp0") | .pppoe.mru' "$INTERFACES_FILE")
MTU_PPP0=$(jq '.[] | select(.identification.id == "ppp0") | .status.mtu' "$INTERFACES_FILE")
CURRENT_MTU_PPP0=$(jq '.[] | select(.identification.id == "ppp0") | .status.currentmtu' "$INTERFACES_FILE")

if [[ "$MRU_PPP0" -ne 1500 || "$MTU_PPP0" -ne 1500 || "$CURRENT_MTU_PPP0" -ne 1500 ]]; then
    jq 'map(if .identification.id == "ppp0" then .pppoe.mru = 1500 | .status.mtu = 1500 | .status.currentmtu = 1500 else . end)' "$INTERFACES_FILE" > "$TEMP_FILE" && mv -f "$TEMP_FILE" "$INTERFACES_FILE"
    log "Changed MRU, MTU, and current MTU for pppoe (ppp0) to 1500"
    MODIFIED=true
fi

# Modify MSS Clamp Size for ipv4 in ppp0
log "Checking current ipv4 MSS Clamp Size for ppp0"
MSS_IPV4=$(jq '.[] | select(.identification.id == "ppp0") | .ipv4.mssClamping.mssClampSize' "$INTERFACES_FILE")
if [[ "$MSS_IPV4" -ne 1460 ]]; then
    jq 'map(if .identification.id == "ppp0" then .ipv4.mssClamping.mssClampSize = 1460 else . end)' "$INTERFACES_FILE" > "$TEMP_FILE" && mv -f "$TEMP_FILE" "$INTERFACES_FILE"
    log "Changed ipv4 MSS Clamp Size for ppp0 to 1460"
    MODIFIED=true
fi

# Modify MSS Clamp Size for ipv6 in ppp0
log "Checking current ipv6 MSS Clamp Size for ppp0"
MSS_IPV6=$(jq '.[] | select(.identification.id == "ppp0") | .ipv6.mss6Clamping.mssClampSize' "$INTERFACES_FILE")
if [[ "$MSS_IPV6" -ne 1440 ]]; then
    jq 'map(if .identification.id == "ppp0" then .ipv6.mss6Clamping.mssClampSize = 1440 else . end)' "$INTERFACES_FILE" > "$TEMP_FILE" && mv -f "$TEMP_FILE" "$INTERFACES_FILE"
    log "Changed ipv6 MSS Clamp Size for ppp0 to 1440"
    MODIFIED=true
fi

# Apply changes if any modifications were made
if [[ "$MODIFIED" == true ]]; then
    ubios-udapi-client PUT /interfaces @"$INTERFACES_FILE"
#    ubios-udapi-client INTERNAL -r /internal/sync/cmd '"sync_all"'
    log "Applied changes to /interfaces"
else
    log "No changes made to /interfaces"
fi
