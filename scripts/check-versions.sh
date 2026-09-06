#!/usr/bin/env bash
# Every module carries a VERSION file holding a bare semver.
#
# A change to one of these files is what the release workflow turns into the
# tag `<module>-<version>`, and the homelab repo pins its module sources to
# those tags — so a typo here becomes a tag somebody consumes. Checked before
# the commit, not after the push.
set -uo pipefail

status=0
for dir in modules/*/; do
  module=$(basename "$dir")
  file="$dir/VERSION"

  if [ ! -f "$file" ]; then
    echo "check-versions: modules/$module has no VERSION file" >&2
    status=1
    continue
  fi

  version=$(tr -d '[:space:]' <"$file")
  case "$version" in
    [0-9]*.[0-9]*.[0-9]*) ;;
    *)
      echo "check-versions: modules/$module VERSION must be a bare semver like 0.1.9, got '$version'" >&2
      status=1
      continue
      ;;
  esac

  # Exactly the version and a trailing newline — nothing else. `git tag` would
  # happily accept a stray space and produce a tag nobody can pin to.
  if [ "$(cat "$file")" != "$version" ]; then
    echo "check-versions: modules/$module VERSION must contain the version and nothing else" >&2
    status=1
  fi
done

exit "$status"
