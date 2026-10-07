# Requires Terraform >= 1.7 for mock_provider support.

mock_provider "github" {}

run "rejects_invalid_visibility" {
  command = plan

  variables {
    name       = "test-repo"
    visibility = "secret"
  }

  expect_failures = [var.visibility]
}

run "rejects_invalid_ruleset_enforcement" {
  command = plan

  variables {
    name = "test-repo"
    rulesets = {
      main = {
        name        = "main"
        enforcement = "nope"
        rules       = {}
      }
    }
  }

  expect_failures = [var.rulesets]
}

run "rejects_invalid_actor_type" {
  command = plan

  variables {
    name = "test-repo"
    rulesets = {
      main = {
        name  = "main"
        rules = {}
        bypass_actors = [
          {
            actor_type  = "Robot"
            bypass_mode = "always"
          }
        ]
      }
    }
  }

  expect_failures = [var.rulesets]
}

run "rejects_review_count_out_of_range" {
  command = plan

  variables {
    name = "test-repo"
    rulesets = {
      main = {
        name = "main"
        rules = {
          pull_request = {
            required_approving_review_count = 7
          }
        }
      }
    }
  }

  expect_failures = [var.rulesets]
}

run "rejects_invalid_merge_method" {
  command = plan

  variables {
    name = "test-repo"
    rulesets = {
      main = {
        name = "main"
        rules = {
          pull_request = {
            allowed_merge_methods = ["fast-forward"]
          }
        }
      }
    }
  }

  expect_failures = [var.rulesets]
}

run "accepts_valid_inputs" {
  command = plan

  variables {
    name           = "test-repo"
    visibility     = "private"
    default_branch = "main"
    rulesets = {
      main = {
        name = "main-protection"
        rules = {
          deletion = true
          pull_request = {
            required_approving_review_count = 1
          }
        }
        bypass_actors = [
          {
            actor_type  = "OrganizationAdmin"
            bypass_mode = "always"
          }
        ]
      }
    }
  }
}

run "rejects_empty_deployment_branch_patterns" {
  command = plan

  variables {
    name = "test-repo"
    environments = {
      release = {
        deployment_branch_patterns = []
      }
    }
  }

  expect_failures = [var.environments]
}

run "rejects_invalid_allowed_actions" {
  command = plan

  variables {
    name = "test-repo"
    actions_permissions = {
      allowed_actions = "everything"
    }
  }

  expect_failures = [var.actions_permissions]
}

run "environment_limited_to_main" {
  command = plan

  variables {
    name = "test-repo"
    environments = {
      release = {
        deployment_branch_patterns = ["main"]
        can_admins_bypass          = false
      }
      preview = {}
    }
    actions_permissions = {
      sha_pinning_required = true
    }
  }

  assert {
    condition     = length(github_repository_environment.this) == 2
    error_message = "both environments should be planned"
  }

  assert {
    condition     = length(github_repository_environment.this["release"].deployment_branch_policy) == 1 && length(github_repository_environment.this["preview"].deployment_branch_policy) == 0
    error_message = "only an environment with patterns gets a custom branch policy"
  }

  assert {
    condition     = keys(github_repository_environment_deployment_policy.this) == ["release:main"]
    error_message = "release should get exactly one deployment policy, for main"
  }

  assert {
    condition     = github_actions_repository_permissions.this[0].sha_pinning_required && github_actions_repository_permissions.this[0].allowed_actions == "all"
    error_message = "actions_permissions should default allowed_actions to all and carry sha_pinning_required"
  }
}

run "defaults_manage_neither" {
  command = plan

  variables {
    name = "test-repo"
  }

  assert {
    condition     = length(github_repository_environment.this) == 0 && length(github_actions_repository_permissions.this) == 0
    error_message = "environments and the Actions policy are opt-in"
  }
}
