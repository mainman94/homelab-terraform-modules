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
| `make versions`           | Show the version each module will release as          |
| `make release-check`      | Which versions are already tagged, and which are not   |
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

## Releases

Consumers pin by tag — `homelab/terraform/*/main.tf` carries
`?ref=github-0.1.9` and friends — so a change that reaches `main` without a
new tag is a change nobody can consume. It sits there looking released while
every tag points at an older commit. That has already happened once.

**Each module carries a `VERSION` file holding a bare semver, and changing it
is the release.** A push to `main` that touches one runs
`.github/workflows/release.yml`, which tags `<module>-<version>` and cuts a
GitHub release. Nothing is tagged by hand.

```text
modules/github/VERSION   →  0.1.9  →  tag github-0.1.9
```

`scripts/release.sh` is idempotent: a version that already has its tag is
skipped, so a push that bumps one module leaves the others alone and a re-run
does nothing. It also means the workflow's token creates the tag — a
contributor's credentials may not be able to, which is how this process came
about.

Two checks keep it honest:

- **`module-versions`** (pre-commit) — a `VERSION` must be a bare semver and
  nothing else. A stray `v` or trailing space becomes a tag somebody pins to,
  so it is caught before the push.
- **`version bump`** (CI, pull requests only) — a module whose **Terraform**
  changed must also bump its `VERSION`. README and example edits do not count:
  they do not change what a consumer gets from a pinned tag.

To release: bump the file in the same pull request as the change, and say in
the commit message what moved. `make release-check` shows which versions are
already tagged.

## Agent tooling

`.claude/` is checked in, so every agent working here starts from the same
setup:

- **`agents/module-reviewer.md`** — reviews a diff for breaking changes to
  consumers, missing validation or tests, and convention drift. Nothing here
  plans against a real account, so a consumer's plan is where a mistake
  surfaces; ask for this review before pushing a variable change.
- **`skills/new-module/SKILL.md`** — scaffolds a module with the full shape
  (`examples/basic/`, README, `tests/`, `VERSION`), which is easy to
  half-finish by hand.
- **`hooks/guard-secrets.sh`** (PreToolUse) blocks a write that would put a
  credential in the repo; **`hooks/format-terraform.sh`** (PostToolUse) runs
  `terraform fmt` on what was just written, so `fmt -check` does not fail on
  whitespace.

The hooks fire automatically from `settings.json`; the agent and skill are
invoked deliberately.

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
