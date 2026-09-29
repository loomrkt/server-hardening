# server-hardening

Configuration reproductible d'un serveur **Ubuntu** avec Ansible.
Partir d'un serveur vide → un seul script → serveur durci.
Basé sur les recommandations d'un audit [Lynis](https://cisofy.com/lynis/) (objectif : indice > 85).

## Ce que ça configure

| Rôle | Effet |
|---|---|
| `base` | MAJ auto de sécurité, politique de mots de passe (pwquality, `login.defs`, umask 027), bannières légales, chrony, acct, permissions cron, debsums |
| `ssh` | Clé uniquement, root interdit, `AllowUsers`, MaxAuthTries 3, pas de forwarding… (drop-in `sshd_config.d/00-hardening.conf`) |
| `firewall` | UFW : tout entrant refusé, SSH en `limit`, ports extra via variables |
| `fail2ban` | Jail sshd propre dans `jail.d/` (plus de doublon de section) |
| `sysctl` | Durcissement noyau/réseau (`/etc/sysctl.d/99-hardening.conf`) |
| `hardening` | Protocoles rares et usb-storage désactivés, `/dev/shm` noexec, rkhunter/chkrootkit, AppArmor |
| `auditd` | Règles d'audit (identité, sudo, ssh, cron, modules) |
| `aide` | Base d'intégrité des fichiers initialisée, SHA512 |

## Utilisation

```bash
# 1. AVANT TOUT : ta clé publique doit être dans ~/.ssh/authorized_keys
ssh-copy-id nameno@IP_DU_SERVEUR

# 2. Sur le serveur
git clone <ton-repo> && cd server-hardening
nano group_vars/all.yml        # adapte admin_user, ports, ignoreip…
./bootstrap.sh                 # installe Ansible, simule, puis applique

# 3. Vérifier
./scripts/audit.sh             # Lynis en root
```

Depuis ton PC vers un serveur distant : édite `inventory/hosts.yml` puis
`ansible-playbook site.yml --check --diff` puis `ansible-playbook site.yml`.

Un seul rôle : `ansible-playbook site.yml --tags ssh`

## ⚠️ Sécurité : ne pas se verrouiller dehors

- Le rôle `ssh` **refuse de s'exécuter** si `authorized_keys` est vide.
- Garde **une session ouverte** pendant que tu testes une *nouvelle* connexion.
- Si tu changes `ssh_port`, ajoute-le aussi côté client. Sur Ubuntu récent, SSH peut être
  en activation par socket (`ssh.socket`) : vérifie que le nouveau port est bien écouté (`ss -tlnp`).
- Si tu ouvres des services (web…), ajoute les ports dans `ufw_extra_tcp_ports`.

## Volontairement non automatisé

- **Mot de passe GRUB** : inutile sur une VM cloud (accès console via le fournisseur).
- **`kernel.modules_disabled=1`** : commenté dans le sysctl, casse Docker/VPN.
- **Partitions séparées `/home`, `/var`** : à décider à l'installation.
- **Log distant** : dépend de ton infra (rsyslog vers un collecteur).
- **`-e 2` dans auditd** (config verrouillée) : décommente en production.
- **Hardening systemd des services** (`UNSAFE` dans Lynis) : peu prioritaire, à faire service par service.

## Développement

```bash
make syntax   # vérification syntaxe
make lint     # ansible-lint
make check    # dry-run
```
