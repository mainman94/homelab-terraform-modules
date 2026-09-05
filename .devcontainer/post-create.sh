#!/usr/bin/env bash
# Provision the dev container. trivy has no devcontainer feature, so it is
# installed from Aqua's apt repository at whatever version is current.
set -euo pipefail

echo "==> installing pre-commit"
pipx install pre-commit 2>/dev/null || pip install --user --break-system-packages pre-commit
export PATH="$HOME/.local/bin:$PATH"

echo "==> installing trivy"
sudo apt-get update -qq
sudo apt-get install -y -qq wget gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list >/dev/null
sudo apt-get update -qq
sudo apt-get install -y -qq trivy

echo "==> installing the git hook"
pre-commit install

echo "==> warming hook environments"
pre-commit install-hooks

cat <<'MSG'

homelab-terraform-modules dev container ready.

  make help                list every target
  make check               hooks + validate + tftest across every module
  make test MODULE=github  one module's tftest suite

The tftest suites use mock providers, so they need no real credentials.
MSG
