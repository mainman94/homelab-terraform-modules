#!/usr/bin/env bash
# Tag and release every module whose VERSION is not yet tagged.
#
# Run by .github/workflows/release.yml on a push to main that touches a
# VERSION file. Idempotent: a version that already has a tag is skipped, so a
# re-run, or a push that changes one module's VERSION and not another's, does
# nothing surprising.
set -uo pipefail

status=0
released=0

for dir in modules/*/; do
  module=$(basename "$dir")
  file="$dir/VERSION"
  [ -f "$file" ] || continue

  version=$(tr -d '[:space:]' <"$file")
  tag="$module-$version"

  if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "$tag already exists — skipping"
    continue
  fi

  echo "==> tagging $tag"
  if ! git tag -a "$tag" -m "$tag"; then
    echo "release: could not create tag $tag" >&2
    status=1
    continue
  fi
  if ! git push origin "refs/tags/$tag"; then
    echo "release: could not push tag $tag" >&2
    status=1
    continue
  fi

  # A release is not required for the tag to be usable — consumers pin the
  # tag, not the release — so a failure here is reported without failing the
  # run that already published the tag.
  if ! gh release create "$tag" \
    --title "$tag" \
    --notes "Terraform module \`$module\` $version.

Pin it with:

\`\`\`hcl
source = \"git::https://github.com/mainman94/homelab-terraform-modules.git//modules/$module?ref=$tag\"
\`\`\`" \
    --generate-notes \
    --verify-tag; then
    echo "release: tag $tag is pushed but the GitHub release could not be created" >&2
  fi

  released=$((released + 1))
done

if [ "$released" -eq 0 ] && [ "$status" -eq 0 ]; then
  echo "nothing to release — every VERSION already has its tag"
fi

exit "$status"
