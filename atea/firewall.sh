#!/usr/bin/env bash
# Block all container egress via DOCKER-USER with firewalld direct rules.
# Works across Docker reinstalls and new bridge names.

set -euo pipefail

need_root() { [ "$(id -u)" -eq 0 ] || { echo "Run as root"; exit 1; }; }
have() { command -v "$1" >/dev/null 2>&1; }

add_rule() {
  local fam="$1"  # ipv4|ipv6
  shift
  firewall-cmd --permanent --direct --add-rule "$fam" filter DOCKER-USER 0 "$@"
}

main() {
  need_root

  if ! have firewall-cmd; then
    echo "error: firewalld is not installed. Install/enable firewalld or use an iptables-persistent approach."
    exit 1
  fi

  # Ensure firewalld is up (no-op if already running)
  systemctl enable --now firewalld >/dev/null 2>&1 || true

  echo "[*] Clearing any previous permanent direct rules on DOCKER-USER…"
  # Remove existing DOCKER-USER direct rules (safe even if none exist)
  firewall-cmd --permanent --direct --remove-rules ipv4 filter DOCKER-USER || true
  firewall-cmd --permanent --direct --remove-rules ipv6 filter DOCKER-USER || true

  echo "[*] Installing permanent deny-by-default egress rules for containers…"
  # 1) Allow return traffic from docker bridges (scoped) so established flows aren't broken
  add_rule ipv4 -i br+      -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
  add_rule ipv4 -i docker0  -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN
  add_rule ipv6 -i br+      -m conntrack --ctstate RELATED,ESTABLISHED -j RETURN

  # 2) DROP all NEW connections from any docker bridge (this blocks *all* egress, incl. ping)
  add_rule ipv4 -i br+      -m conntrack --ctstate NEW -j DROP
  add_rule ipv4 -i docker0  -m conntrack --ctstate NEW -j DROP
  add_rule ipv6 -i br+      -m conntrack --ctstate NEW -j DROP

  # 3) Hand control back for everything else
  add_rule ipv4 -j RETURN
  add_rule ipv6 -j RETURN

  echo "[*] Reloading firewalld to apply permanent rules…"
  firewall-cmd --reload

  # Optional: ensure Docker running (creates DOCKER-USER chain if not present yet)
  systemctl restart docker || true

  echo "[*] Done. All NEW egress from Docker containers is blocked."
  echo
  echo "Quick test (should fail):"
  echo "  docker run --rm alpine sh -c 'ping -c1 1.1.1.1 || echo blocked'"
  echo "  docker run --rm curlimages/curl -sS https://example.com || echo blocked"
  echo
  echo "NOTE:"
  echo "  - Containers started with --network=host bypass bridges; avoid using it."
  echo "  - To allow LAN-only egress later, add RETURNs before the DROP (10/172.16-31/192.168)."
}

main "$@"