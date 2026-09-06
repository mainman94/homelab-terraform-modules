# Security Policy

## What this repository is

Shared Terraform modules for Cloudflare, GitHub and Backblaze, consumed by the
`homelab` repository's root stacks. There is no state and no backend here, and
the modules hold no credentials: authentication is always the calling root
module's job.

## Reporting

Report privately via GitHub's
[security advisories](https://github.com/mainman94/homelab-terraform-modules/security/advisories/new).
Please do not open a public issue for anything exploitable.

Worth reporting: a module default that is insecure (a public bucket, a
permissive ruleset, a disabled protection), or an input that reaches a
provider unvalidated in a way that could widen access.

## What is already covered

- **`provider.tf` declares `required_providers` only.** A module never
  configures a provider, so a token cannot be captured here.
- **`gitleaks`** runs as a pre-commit hook and in CI.
- **`trivy config`** scans the modules for misconfiguration on every pull
  request and uploads SARIF to the Security tab.
- **tftest suites use `mock_provider`**, so tests need no real credentials.
- **Every action reference in CI is pinned to a commit SHA**, and `zizmor`
  audits the workflows for CI/CD security patterns.

## A note on blast radius

A change here lands in a real plan in a separate repository, against live
infrastructure. A module that silently widens permissions is therefore worth
reporting even when nothing in this repository looks exploitable on its own.
