#!/usr/bin/env bash
# Allow Docker containers to reach private IPv4 addresses only; block all other egress.
# Uses firewalld direct rules in the DOCKER-USER chain (IPv4 only).

set -euo pipefail

need_root() { [ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }; }
have() { command -v "$1" >/dev/null 2>&1; }
add_rule() { firewall-cmd --permanent --direct --add-rule ipv4 filter DOCKER-USER 0 "$@"; }

main() {
  need_root
  have firewall-cmd || { echo "error: firewalld not installed"; exit 1; }
  firewall-cmd --permanent --direct --remove-rules ipv4 filter DOCKER-USER || true
  # Ensure firewalld is running
  systemctl enable --now firewalld >/dev/null 2>&1 || true

  echo "[*] Clearing previous DOCKER-USER IPv4 direct rules…"
  firewall-cmd --permanent --direct --remove-rules ipv4 filter DOCKER-USER || true

  echo "[*] Installing private-only egress policy for Docker (IPv4)…"

  # 1) Allow return traffic from docker bridges (keep established flows working)
  add_rule -i br+     -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
  add_rule -i docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN

  # 2) Allow NEW connections from docker bridges to private ranges
  # RFC1918:
  add_rule -i br+     -d 10.0.0.0/8      -m conntrack --ctstate NEW -j RETURN
  add_rule -i br+     -d 172.16.0.0/12   -m conntrack --ctstate NEW -j RETURN
  add_rule -i br+     -d 192.168.0.0/16  -m conntrack --ctstate NEW -j RETURN
  add_rule -i docker0 -d 10.0.0.0/8      -m conntrack --ctstate NEW -j RETURN
  add_rule -i docker0 -d 172.16.0.0/12   -m conntrack --ctstate NEW -j RETURN
  add_rule -i docker0 -d 192.168.0.0/16  -m conntrack --ctstate NEW -j RETURN

  # Optional: allow CGNAT (uncomment if you use 100.64.0.0/10 internally)
  # add_rule -i br+     -d 100.64.0.0/10   -m conntrack --ctstate NEW -j RETURN
  # add_rule -i docker0 -d 100.64.0.0/10   -m conntrack --ctstate NEW -j RETURN

  # 3) Drop all other NEW egress from docker bridges (blocks internet)
  add_rule -i br+     -m conntrack --ctstate NEW -j DROP
  add_rule -i docker0 -m conntrack --ctstate NEW -j DROP

  # 4) Default: hand control back for everything else
  add_rule -j RETURN

  echo "[*] Reloading firewalld…"
  firewall-cmd --reload

  # Ensure Docker is up (so bridges/chains exist)
  systemctl restart docker || true

  echo "[*] Done. Containers can reach 10/8, 172.16/12, 192.168/16; all other IPv4 egress is blocked."
  echo "Test:"
  echo "  docker run --rm alpine sh -c 'ping -c1 1.1.1.1 || echo internet blocked'"
  echo "  docker run --rm alpine sh -c 'ping -c1 10.0.0.1 || echo private allowed'"
}

main "$@"
