# homelab-terraform-modules — shared modules consumed by the homelab repo.
#
# TF is `tofu` when OpenTofu is installed and `terraform` otherwise; override
# with `make TF=terraform ...`. Targets that need providers (validate, test)
# run `init -backend=false` first — these modules have no backend of their own.

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

TF ?= $(shell command -v tofu 2>/dev/null || command -v terraform 2>/dev/null || echo terraform)

# pre-commit-terraform prefers `terraform`; on a tofu-only machine the
# terraform_* hooks need telling. mise.toml sets the same value for anyone
# using the dev container.
export PCT_TFPATH ?= $(TF)
MODULES := $(patsubst modules/%/,%,$(wildcard modules/*/))

# `make test MODULE=github` narrows any per-module target to one module.
MODULE ?=
TARGETS := $(if $(MODULE),$(MODULE),$(MODULES))

.PHONY: help
help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "  Per-module targets take MODULE=<name>, e.g. make test MODULE=github"
	@echo "  Modules: $(MODULES)"

.PHONY: tools
tools: ## Install the pinned toolchain from mise.toml
	@command -v mise >/dev/null || { echo "mise not on PATH — see https://mise.jdx.dev or .devcontainer" >&2; exit 1; }
	mise install

.PHONY: hooks
hooks: ## Install the git pre-commit hook
	pre-commit install

.PHONY: lint
lint: ## Run every pre-commit hook over the whole tree
	pre-commit run --all-files

.PHONY: fmt
fmt: ## Rewrite Terraform files to canonical format
	$(TF) fmt -recursive

.PHONY: docs
docs: ## Regenerate the terraform-docs block in each module README
	pre-commit run terraform_docs --all-files

.PHONY: init
init: ## Download providers for each module (no backend)
	@for m in $(TARGETS); do \
		echo "==> init $$m"; \
		$(TF) -chdir=modules/$$m init -backend=false -input=false; \
	done

.PHONY: validate
validate: init ## terraform validate each module
	@for m in $(TARGETS); do \
		echo "==> validate $$m"; \
		$(TF) -chdir=modules/$$m validate; \
	done

.PHONY: test
test: init ## Run each module's tftest suite (mock providers, no credentials)
	@for m in $(TARGETS); do \
		echo "==> test $$m"; \
		$(TF) -chdir=modules/$$m test; \
	done

.PHONY: lint-deep
lint-deep: ## tflint including provider rulesets (fetches plugins)
	@for m in $(TARGETS); do \
		echo "==> tflint $$m"; \
		tflint --chdir=modules/$$m --config="$(CURDIR)/.tflint.hcl" --init; \
		tflint --chdir=modules/$$m --config="$(CURDIR)/.tflint.hcl"; \
	done

.PHONY: scan
scan: ## Scan the modules for misconfigurations (advisory, like CI)
	@command -v trivy >/dev/null || { echo "trivy not on PATH — run make tools" >&2; exit 1; }
	trivy config modules/

.PHONY: scan-strict
scan-strict: ## Same scan, but fail on any finding
	@command -v trivy >/dev/null || { echo "trivy not on PATH — run make tools" >&2; exit 1; }
	trivy config --exit-code 1 modules/

.PHONY: security
security: scan ## Alias for scan

.PHONY: check
check: lint validate test ## Everything a PR needs to pass

.PHONY: clean
clean: ## Remove downloaded providers
	rm -rf modules/*/.terraform

.PHONY: update-hooks
update-hooks: ## Bump pinned hook revisions
	pre-commit autoupdate
