# GitHub Terraform Module

Terraform module for managing a GitHub repository, its default branch, and optional repository rulesets.

## Features

- Manages a `github_repository`
- Optionally manages the repository default branch with `github_branch_default`
- Optionally manages `github_repository_ruleset` resources for branch governance
- Exposes repository identifiers and URLs as outputs

## Requirements

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}
```

Provider authentication is expected to be configured by the calling root module.

## Usage

```hcl
provider "github" {
  token = var.github_token
  owner = var.github_owner
}

module "repository" {
  source = "git::https://github.com/mainman94/homelab-terraform-modules.git//modules/github"

  name           = "homelab"
  visibility     = "public"
  has_issues     = true
  has_projects   = false
  has_wiki       = false
  allow_forking  = true
  default_branch = "main"

  rulesets = {
    default_branch = {
      name = "default-branch-protection"
      rules = {
        deletion                = true
        non_fast_forward        = true
        required_linear_history = true
        pull_request = {
          dismiss_stale_reviews_on_push    = true
          required_approving_review_count  = 1
          required_review_thread_resolution = true
        }
      }
    }
  }
}
```

## Importing an existing repository

After wiring the module in a root stack, import the existing repository into state:

```bash
terraform import module.homelab_repository.github_repository.this homelab
terraform import 'module.homelab_repository.github_branch_default.this[0]' homelab
```

The repository import uses the repository name within the configured owner.

## Inputs

| Name                     | Type               | Default     | Description                                                |
| ------------------------ | ------------------ | ----------- | ---------------------------------------------------------- |
| `name`                   | `string`           | n/a         | Repository name.                                           |
| `description`            | `string`           | `null`      | Repository description.                                    |
| `homepage_url`           | `string`           | `null`      | Repository homepage URL.                                   |
| `visibility`             | `string`           | `"private"` | Repository visibility.                                     |
| `topics`                 | `set(string)`      | `[]`        | Repository topics.                                         |
| `has_issues`             | `bool`             | `true`      | Whether issues are enabled.                                |
| `has_projects`           | `bool`             | `false`     | Whether projects are enabled.                              |
| `has_wiki`               | `bool`             | `false`     | Whether the wiki is enabled.                               |
| `allow_merge_commit`     | `bool`             | `null`      | Whether merge commits are allowed.                         |
| `allow_squash_merge`     | `bool`             | `null`      | Whether squash merges are allowed.                         |
| `allow_rebase_merge`     | `bool`             | `null`      | Whether rebase merges are allowed.                         |
| `allow_auto_merge`       | `bool`             | `null`      | Whether auto-merge is allowed.                             |
| `delete_branch_on_merge` | `bool`             | `null`      | Whether merged branches are deleted automatically.         |
| `allow_update_branch`    | `bool`             | `null`      | Whether pull requests can be updated with the base branch. |
| `allow_forking`          | `bool`             | `null`      | Whether the repository can be forked.                      |
| `archived`               | `bool`             | `false`     | Whether the repository is archived.                        |
| `archive_on_destroy`     | `bool`             | `true`      | Archive instead of deleting on destroy.                    |
| `vulnerability_alerts`   | `bool`             | `null`      | Whether vulnerability alerts are enabled.                  |
| `secret_scanning`        | `bool`             | `null`      | Whether secret scanning is enabled.                        |
| `secret_scanning_push_protection` | `bool`    | `null`      | Whether secret scanning push protection is enabled.        |
| `default_branch`         | `string`           | `null`      | Default branch to manage.                                  |
| `rulesets`               | `map(object(...))` | `{}`        | Branch rulesets keyed by a stable Terraform identifier.    |

## Outputs

| Name                        | Description                                                 |
| --------------------------- | ----------------------------------------------------------- |
| `repository_id`             | GitHub repository node ID.                                  |
| `repository_name`           | GitHub repository name.                                     |
| `repository_full_name`      | GitHub repository full name.                                |
| `repository_html_url`       | GitHub repository HTML URL.                                 |
| `repository_default_branch` | Managed default branch name, or `null` when not configured. |
| `ruleset_ids`               | Map of ruleset Terraform keys to GitHub ruleset node IDs.   |
