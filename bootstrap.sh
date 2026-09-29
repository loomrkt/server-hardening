#!/usr/bin/env bash
# Sur un serveur vide : installe Ansible puis applique la config en local.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v ansible-playbook >/dev/null; then
  echo ">> Installation d'Ansible..."
  sudo apt-get update -qq
  sudo apt-get install -y ansible git
fi

echo ">> Simulation (--check --diff)..."
ansible-playbook site.yml --check --diff || {
  echo "La simulation a échoué, rien n'a été appliqué."; exit 1; }

read -r -p "Appliquer pour de vrai ? [y/N] " ans
[[ "$ans" =~ ^[yY]$ ]] || exit 0
ansible-playbook site.yml
echo ">> Terminé. Teste une NOUVELLE connexion SSH avant de fermer celle-ci !"
