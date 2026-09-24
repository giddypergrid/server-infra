#!/bin/sh
# One-time base setup for a fresh Ubuntu 24.04 server. Safe to re-run.
# Run as root AFTER your SSH key is in ~/.ssh/authorized_keys, or the lockdown step locks you out.
set -e

# Tools: git to clone projects, ufw for the firewall, rsync to move data between servers.
apt-get update
apt-get install -y git ufw rsync

# Docker + the compose plugin, from Docker's official script.
command -v docker >/dev/null || curl -fsSL https://get.docker.com | sh

# Firewall: SSH, HTTP and HTTPS only. Apps are reached through Caddy, never directly.
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Key-only SSH. 00- sorts before Ubuntu's 50-cloud-init.conf, and sshd keeps the first value it reads.
printf 'PasswordAuthentication no\nPermitRootLogin prohibit-password\n' > /etc/ssh/sshd_config.d/00-hardening.conf
sshd -t && systemctl reload ssh

# Shared network that Caddy and every app join.
docker network inspect web >/dev/null 2>&1 || docker network create web

echo "Base setup done. Open a NEW terminal and check 'ssh <server>' still works before closing this one."
