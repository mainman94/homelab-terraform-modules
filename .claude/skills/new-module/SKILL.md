---
name: new-module
description: Scaffold a new shared Terraform module with the repo's full shape — examples, generated docs and a tftest suite. Use when adding a module under modules/.
---

# new-module

A module here is not finished until a consumer can copy `examples/basic/` and a PR can
prove the inputs behave. Build it in this order.

## Steps

1. **Create the layout** under `modules/<name>/`:

   ```text
   main.tf, variables.tf, outputs.tf, provider.tf
   README.md              # prose, then the BEGIN_TF_DOCS/END_TF_DOCS markers
   examples/basic/        # a minimal, runnable call
   tests/validation.tftest.hcl
   ```

2. **`provider.tf` declares `required_providers` only.** Never configure a provider inside
   a module — the calling root stack owns authentication.

3. **Every variable gets a `description`**, and a `validation` block wherever the value is
   constrained (a set of allowed strings, a length, a format).

4. **Write the tests before the docs.** `tests/validation.tftest.hcl` uses `mock_provider`
   so it needs no credentials. Each `validation` block gets a `run` with `expect_failures`
   asserting it rejects bad input.

5. **Generate the docs**: write the prose in README.md, add the `BEGIN_TF_DOCS` marker
   pair, then `make docs`. Do not hand-write an Inputs or Outputs table — that is what
   drifted before.

6. **Verify**: `make check MODULE=<name>` (hooks + validate + tftest), then
   `make lint-deep MODULE=<name>` if the module uses provider-specific resources.

## Then

Adding the module is half the change: the `homelab` repo has to call it. Say in the commit
message which root stack is expected to consume it, and whether anything there breaks.
