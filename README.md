# homelab-terraform-modules

Shared Terraform modules consumed by the root stacks in
[`mainman94/homelab`](https://github.com/mainman94/homelab).

There is no state and no backend here. Nothing in this repository plans against
a real account on its own — a change lands in a real plan somewhere else, once a
consumer bumps its pin. That is why the checks below matter more than they
usually would.

## Modules

| Module | What it manages |
| --- | --- |
| [`modules/cloudflare`](modules/cloudflare) | DNS records (A, CNAME, tunnel-backed CNAME, SPF/DKIM TXT) and email routing rules |
| [`modules/github`](modules/github) | A repository, its default branch, Dependabot security updates, and repository rulesets |
| [`modules/backblaze`](modules/backblaze) | A Backblaze B2 bucket |

Each module has its own README with a generated inputs/outputs table, a
runnable `examples/basic/`, and a `tests/validation.tftest.hcl`.

## Using a module

Consumers pin by **tag**, never by branch:

```hcl
module "repository" {
  source = "git::https://github.com/mainman94/homelab-terraform-modules.git//modules/github?ref=github-0.1.9"

  # ...
}
```

Copy the call shape from that module's `examples/basic/`. Modules declare
`required_providers` only — configuring and authenticating the provider is the
calling root module's job, so a module never contains a `provider` block.

After changing a `ref`, run `terraform init -upgrade`. Plain `terraform init`
reuses the cached module and will happily plan the old code against the new
pin.

## Releases

**A module's `VERSION` file holds a bare semver, and changing it is the
release.** A push to `main` that touches one runs `.github/workflows/release.yml`,
which tags `<module>-<version>` and cuts a GitHub release. Nothing is tagged by
hand.

```text
modules/github/VERSION   →  0.1.9  →  tag github-0.1.9
```

So the flow is: change the module and bump its `VERSION` in the same pull
request; merging publishes the tag; then bump the `ref` in the consumer.

Two checks keep that honest:

- **`module-versions`** (pre-commit) rejects a `VERSION` that is not a bare
  semver. A stray `v` or a trailing space becomes a tag somebody pins to.
- **`version bump`** (CI) fails a pull request that changes a module's
  Terraform without bumping its `VERSION`. README and example edits are exempt —
  they do not change what a consumer gets from a pinned tag.

`make release-check` shows which versions are already tagged and which are not.
`scripts/release.sh` is idempotent, so a push that bumps one module leaves the
others alone.

## Local development

```bash
make tools   # install the pinned toolchain from mise.toml
make hooks   # install the git pre-commit hook, once
make check   # what a PR needs: hooks + validate + tftest
```

`make help` lists the rest. **Tool versions live in `mise.toml` and nowhere
else** — tofu, tflint, terraform-docs, trivy, actionlint, python and pre-commit.
CI installs from the same file, so a local run and a CI run agree.

`make` prefers `tofu` and falls back to `terraform`; override with
`make TF=terraform ...`. Unlike the `homelab` repo, nothing here uses
`ephemeral`, so OpenTofu works fine.

Two things are easy to trip over:

- **Module READMEs are generated below `BEGIN_TF_DOCS`.** Write prose above the
  marker; terraform-docs owns everything below it, and pre-commit fails when the
  block is stale.
- **Tests use `mock_provider`**, so they need no credentials — but
  `terraform init` still downloads providers before a test can plan.

## What CI runs

Five checks are required before a pull request can merge: `pre-commit`,
`tftest (backblaze)`, `tftest (cloudflare)`, `tftest (github)` and `trivy`.
`version bump` runs on pull requests as described above.

The trivy config scan is advisory — it uploads SARIF to the Security tab rather
than failing on a rule nobody has triaged. `make scan-strict` is the gating
version, for when you want it to fail.

Every action reference in `.github/workflows/` is pinned to a commit SHA with
the tag in a trailing comment; Renovate keeps the digests current. A moving tag
can be repointed at new code without the pin changing, so please do not "tidy"
one back to `@v7`.

## Contributing

[`AGENTS.md`](AGENTS.md) is the detailed guide — layout, conventions, what the
checks do and, more usefully, what they cannot see. Note that changing a
variable's name, type or default is a breaking change for the `homelab` repo;
say so in the commit message.

## License and security

MIT ([`LICENSE`](LICENSE)). To report a vulnerability, see
[`SECURITY.md`](SECURITY.md) — please do not open a public issue for one.
