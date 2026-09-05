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
| `make hooks`              | Install the git pre-commit hook (do this once)        |
| `make check`              | Everything a PR needs: hooks + validate + tftest      |
| `make test MODULE=github` | One module's tftest suite                             |
| `make validate`           | `terraform validate` each module                      |
| `make docs`               | Regenerate the terraform-docs block in each README    |
| `make fmt`                | Rewrite to canonical format                           |
| `make security`           | trivy misconfiguration scan                           |
| `make lint-deep`          | tflint with provider rulesets (fetches plugins)       |

`make` uses `tofu` when OpenTofu is installed and `terraform` otherwise;
override with `make TF=terraform ...`. `.devcontainer/` provides tofu, tflint,
terraform-docs, trivy and the hook toolchain.

## Automated checks

`.pre-commit-config.yaml` runs on every commit: `terraform_fmt`,
`terraform_docs`, `terraform_tflint` (core ruleset only, see `.tflint.hcl`),
plus hygiene hooks and `gitleaks`.

Anything needing `terraform init` — `validate`, `tofu test`, provider-aware
tflint rules — pulls providers over the network on every run, which is too
slow for a commit hook. Those live in `make validate`, `make test` and
`make lint-deep`, and are what `make check` runs before a PR.

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
