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
