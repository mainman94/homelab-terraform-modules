## What

<!-- One or two sentences. -->

## Why

<!-- The problem this solves. Link the issue if there is one. -->

## Breaking change?

<!-- These modules are consumed by the homelab repo, where a change lands in
     a real plan. Renaming a variable, changing its type or its default is
     breaking — say so here, or write "no". -->

## Checklist

- [ ] `make check` passes (hooks + validate + tftest across every module)
- [ ] New constrained variable has a `validation` block **and** a `run` block
      in `tests/` asserting it rejects bad input
- [ ] `terraform-docs` block regenerated with `make docs` — not hand-edited
      inside the `BEGIN_TF_DOCS` markers
- [ ] New module has the full shape: `examples/basic/`, a README, and
      `tests/validation.tftest.hcl`
