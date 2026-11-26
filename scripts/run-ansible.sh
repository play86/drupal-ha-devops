#!/usr/bin/env bash
set -euo pipefail

LIMIT="${1:-all}"
RUNNER_IP="$(curl -s https://checkip.amazonaws.com | tr -d '[:space:]')"

cleanup() {
  aws ec2 revoke-security-group-ingress --group-id "$BASTION_SG_ID" \
    --protocol tcp --port 22 --cidr "${RUNNER_IP}/32" || true
}
trap cleanup EXIT

aws ec2 authorize-security-group-ingress --group-id "$BASTION_SG_ID" \
  --protocol tcp --port 22 --cidr "${RUNNER_IP}/32"

mkdir -p ~/.ssh && chmod 700 ~/.ssh
printf '%s\n' "$SSH_PRIVATE_KEY" > ~/.ssh/deploy-key.pem
chmod 600 ~/.ssh/deploy-key.pem

cat > ~/.ssh/config <<SSHCFG
Host 10.*
  User ubuntu
  IdentityFile $HOME/.ssh/deploy-key.pem
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ProxyCommand ssh -W %h:%p -q -i $HOME/.ssh/deploy-key.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${BASTION_IP}
SSHCFG
chmod 600 ~/.ssh/config

cd ansible
printf '%s' "$EXTRA_VARS_JSON" > extra_vars.json
sleep 10

ansible-playbook site.yml --limit "$LIMIT" \
  -e @extra_vars.json \
  -e ansible_ssh_private_key_file="$HOME/.ssh/deploy-key.pem"
