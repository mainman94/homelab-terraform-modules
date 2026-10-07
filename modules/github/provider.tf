terraform {
  required_version = ">= 1.3.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13" # sha_pinning_required on github_actions_repository_permissions
    }
  }
}
