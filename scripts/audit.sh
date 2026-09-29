#!/usr/bin/env bash
# Lance Lynis en root (sinon beaucoup de tests sont sautés).
set -euo pipefail
command -v lynis >/dev/null || sudo apt-get install -y lynis
sudo lynis audit system --quiet --no-colors | tee "lynis-$(date +%F).log" | tail -n 60
sudo grep -E 'hardening_index|warning\[\]' /var/log/lynis-report.dat || true
