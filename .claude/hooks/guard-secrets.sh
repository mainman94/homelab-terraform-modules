#!/usr/bin/env bash
# PreToolUse: block edits to credential-bearing or state files.
# Exit 2 = block the tool call (the stderr message is shown to Claude).
#
# These modules configure Cloudflare, GitHub and Backblaze. A real token
# pasted into an example or a tfvars file would be committed to a public
# repo, so the hook refuses before gitleaks has to catch it.
set -uo pipefail
f=$(jq -r '.tool_input.file_path // empty')
[ -z "$f" ] && exit 0
case "$f" in
  *.tfvars|*.tfvars.json)
    echo "Blocked: '$f' holds real values. Modules take inputs from the caller; use variables.tf defaults or an examples/ block instead." >&2
    exit 2 ;;
  *.tfstate|*.tfstate.*)
    echo "Blocked: state is never edited by hand, and never committed here — these modules have no backend." >&2
    exit 2 ;;
  *settings.local.json|*.env)
    echo "Blocked: '$f' holds local credentials — edit it manually, not via Claude." >&2
    exit 2 ;;
esac
exit 0
