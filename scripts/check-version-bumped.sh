#!/usr/bin/env bash
# A module whose Terraform changed must also carry a new VERSION.
#
# Consumers pin by tag. A module change that ships without a version bump is a
# change nobody can consume: it sits on main, the tags all point at older
# commits, and the next person to look assumes it was released. That is
# exactly how modules/github ended up changed-but-unreleased.
set -uo pipefail

base=${1:?usage: check-version-bumped.sh <base-ref>}

changed=$(scripts/changed-modules.sh "$base")
if [ -z "$changed" ]; then
  echo "no module Terraform changed"
  exit 0
fi

status=0
while read -r module; do
  [ -z "$module" ] && continue
  if git diff --quiet "$base...HEAD" -- "modules/$module/VERSION"; then
    echo "check-version-bumped: modules/$module changed but modules/$module/VERSION did not" >&2
    echo "  Bump it. Merging that file is what tags <module>-<version> and cuts the release." >&2
    status=1
  else
    echo "modules/$module: version bumped to $(tr -d '[:space:]' <"modules/$module/VERSION")"
  fi
done <<<"$changed"

exit "$status"
