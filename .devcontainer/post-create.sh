#!/usr/bin/env bash
# Provision the dev container. Everything the repo needs is pinned in
# mise.toml — tofu, tflint, terraform-docs, trivy, actionlint, python and
# pre-commit — so this script only has to install mise and let it do the
# rest. CI installs from the same file.
set -euo pipefail

echo "==> installing mise"
curl -fsSL https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"

# Activate for interactive shells so the pinned binaries are on PATH.
for shell in bash zsh; do
  rc="$HOME/.${shell}rc"
  [ -f "$rc" ] || continue
  grep -q "mise activate" "$rc" || echo "eval \"\$(mise activate $shell)\"" >> "$rc"
done

echo "==> installing the pinned toolchain"
cd "$(dirname "${BASH_SOURCE[0]}")/.."
mise trust
mise install

echo "==> installing the git hook"
mise exec -- pre-commit install

echo "==> warming hook environments"
mise exec -- pre-commit install-hooks

cat <<'MSG'

homelab-terraform-modules dev container ready.

  make help                list every target
  make check               hooks + validate + tftest across every module
  make test MODULE=github  one module's tftest suite

Tool versions come from mise.toml — the same file CI installs from.
The tftest suites use mock providers, so they need no real credentials.
MSG
