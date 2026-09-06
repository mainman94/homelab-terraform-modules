#!/usr/bin/env bash
# Print the modules whose Terraform changed against a base ref, one per line.
#
# Terraform only: a README or example edit does not change what a consumer
# gets from a pinned tag, so it does not demand a new version.
set -uo pipefail

base=${1:?usage: changed-modules.sh <base-ref>}

git diff --name-only "$base...HEAD" -- 'modules/*/*.tf' 'modules/*/**/*.tf' \
  | awk -F/ '/^modules\//{print $2}' \
  | sort -u
