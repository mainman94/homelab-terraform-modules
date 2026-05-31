terraform {
  required_version = ">= 1.3.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

module "repository" {
  source = "../../"

  name           = var.repository_name
  description    = "Managed by Terraform."
  visibility     = "private"
  default_branch = "main"

  has_issues   = true
  has_projects = false
  has_wiki     = false

  allow_squash_merge     = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  delete_branch_on_merge = true

  vulnerability_alerts = true

  rulesets = {
    main = {
      name = "main-branch-protection"
      rules = {
        deletion         = true
        non_fast_forward = true
        pull_request = {
          required_approving_review_count   = 1
          dismiss_stale_reviews_on_push     = true
          required_review_thread_resolution = true
        }
      }
    }
  }
}

output "repository_url" {
  value = module.repository.repository_html_url
}

output "ruleset_ids" {
  value = module.repository.ruleset_ids
}
