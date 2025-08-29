#!/usr/bin/env bash
set -euo pipefail

sudo firewall-cmd --permanent --add-port=0-65535/udp

# Create chain + hook (persistent)
firewall-cmd --permanent --direct --add-chain ipv4 filter DOCKER-USER 2>/dev/null || true
firewall-cmd --permanent --direct --add-rule  ipv4 filter FORWARD 0 -j DOCKER-USER 2>/dev/null || true

# Established/related
firewall-cmd --permanent --direct --add-rule ipv4 filter DOCKER-USER 0 -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN 2>/dev/null || true

# Bridges: docker0 + br-*
for IFACE in docker0 $(ip -o link show type bridge | awk -F': ' '{print $2}' | grep -E '^br-' || true); do
  for CIDR in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
    firewall-cmd --permanent --direct --add-rule ipv4 filter DOCKER-USER 0 -i "$IFACE" -d "$CIDR" -j RETURN 2>/dev/null || true
  done
  firewall-cmd --permanent --direct --add-rule ipv4 filter DOCKER-USER 1 -i "$IFACE" -j DROP 2>/dev/null || true
done

firewall-cmd --reload
firewall-cmd --direct --get-rules ipv4 filter DOCKER-USER