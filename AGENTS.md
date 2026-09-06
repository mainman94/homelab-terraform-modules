# AGENTS

Shared Terraform modules, consumed by the `homelab` repo's root stacks. There
is no state and no backend here — a change lands in a real plan somewhere
else, which is why the tftest suites matter.

## Layout

```text
modules/<name>/
├── main.tf, variables.tf, outputs.tf, provider.tf
├── README.md              # prose + a generated terraform-docs block
├── examples/basic/        # a minimal, runnable call
└── tests/validation.tftest.hcl
```

Modules: `cloudflare`, `github`, `backblaze`.

## Local workflow

| Command                   | What it does                                          |
| ------------------------- | ----------------------------------------------------- |
| `make help`               | List every target                                     |
| `make tools`              | Install the pinned toolchain from `mise.toml`         |
| `make hooks`              | Install the git pre-commit hook (do this once)        |
| `make check`              | Everything a PR needs: hooks + validate + tftest      |
| `make test MODULE=github` | One module's tftest suite                             |
| `make validate`           | `terraform validate` each module                      |
| `make docs`               | Regenerate the terraform-docs block in each README    |
| `make fmt`                | Rewrite to canonical format                           |
| `make scan`               | trivy misconfiguration scan (advisory, like CI)       |
| `make lint-deep`          | tflint with provider rulesets (fetches plugins)       |

`make` uses `tofu` when OpenTofu is installed and `terraform` otherwise;
override with `make TF=terraform ...`.

**Tool versions live in `mise.toml` and nowhere else.** tofu, tflint,
terraform-docs, trivy, actionlint, python and pre-commit are all pinned there;
the dev container's post-create runs `mise install`, and CI installs from the
same file with `jdx/mise-action`. Before this, the dev container asked for
tflint `latest` while CI pinned 0.64.0 — a new tflint rule failed the PR and
nobody's local run. Bump a version in `mise.toml` and all three move together;
Renovate opens the PR.

## Automated checks

`.pre-commit-config.yaml` runs on every commit: `terraform_fmt`,
`terraform_docs`, `terraform_tflint` (core ruleset only, see `.tflint.hcl`),
`actionlint` and `zizmor` over `.github/workflows/`, plus hygiene hooks and
`gitleaks`.

`actionlint` checks workflow schema, expression syntax and the shell inside
`run:` blocks. `zizmor` audits the same files for CI/CD security patterns —
unpinned actions, credentials left behind by `actions/checkout`, template
injection through `${{ }}` in a run block. It runs as `actionlint-system`,
i.e. the binary `mise.toml` pins, so the hook and CI cannot disagree.

Every action reference in `.github/workflows/` is pinned to a **commit SHA**
with the tag in a trailing comment. A moving tag is a supply-chain hole: the
tag can be repointed at new code without the pin changing. Renovate keeps the
digests current (`helpers:pinGitHubActionDigests`) — do not "tidy" a pin back
to `@v7`.

Anything needing `terraform init` — `validate`, `tofu test`, provider-aware
tflint rules — pulls providers over the network on every run, which is too
slow for a commit hook. Those live in `make validate`, `make test` and
`make lint-deep`, and are what `make check` runs before a PR.

`.github/workflows/ci.yml` runs all three on every PR, so the checks no
longer depend on whoever remembered to install the hook:

- **pre-commit**, with the whole `mise.toml` toolchain installed so every
  hook really runs. A README whose generated block is stale fails here — the
  hook rewrites it and pre-commit reports the file as modified.
- **tftest**, one matrix leg per module. The suites use `mock_provider`, so
  no credentials — but providers still download before `tofu test` can plan.
- **trivy** config scan, uploading SARIF to the Security tab. Advisory: it
  does not block a PR on a rule nobody has triaged. `make scan-strict` is the
  gating version.

## Conventions

- **Docs are generated.** Each README has hand-written prose (Features, Usage,
  notes) above a `BEGIN_TF_DOCS` block that terraform-docs regenerates from
  `variables.tf` and `outputs.tf`. Do not hand-edit inside the markers, and do
  not reintroduce a hand-maintained Inputs or Outputs table — that is what
  drifted before.
- **Every variable carries a `description` and, where the value is
  constrained, a `validation` block.** The tftest suites assert those
  validations reject bad input (`expect_failures`), so a new constrained
  variable should come with a `run` block.
- **Tests use `mock_provider`**, so they need no credentials and run offline
  once providers are cached.
- **`provider.tf` declares `required_providers` only.** Provider
  authentication is the calling root module's job — never configure a provider
  inside a module.
- **A new module gets the full shape**: `examples/basic/`, a README, and a
  `tests/validation.tftest.hcl`. Consumers copy from `examples/`.
- Changing a variable's name, type or default is a breaking change for the
  `homelab` repo. Say so in the commit message.
