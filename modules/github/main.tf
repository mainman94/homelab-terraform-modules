resource "github_repository" "this" {
  name         = var.name
  description  = var.description
  homepage_url = var.homepage_url
  visibility   = var.visibility
  topics       = sort(tolist(var.topics))

  has_issues   = var.has_issues
  has_projects = var.has_projects
  has_wiki     = var.has_wiki

  allow_merge_commit     = var.allow_merge_commit
  allow_squash_merge     = var.allow_squash_merge
  allow_rebase_merge     = var.allow_rebase_merge
  allow_auto_merge       = var.allow_auto_merge
  delete_branch_on_merge = var.delete_branch_on_merge
  allow_update_branch    = var.allow_update_branch
  allow_forking          = var.allow_forking

  archived             = var.archived
  archive_on_destroy   = var.archive_on_destroy
  vulnerability_alerts = var.vulnerability_alerts

  dynamic "security_and_analysis" {
    for_each = var.secret_scanning == null && var.secret_scanning_push_protection == null ? [] : [1]

    content {
      dynamic "secret_scanning" {
        for_each = var.secret_scanning == null ? [] : [1]
        content {
          status = var.secret_scanning ? "enabled" : "disabled"
        }
      }

      dynamic "secret_scanning_push_protection" {
        for_each = var.secret_scanning_push_protection == null ? [] : [1]
        content {
          status = var.secret_scanning_push_protection ? "enabled" : "disabled"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      archive_on_destroy,
    ]
  }
}

resource "github_repository_dependabot_security_updates" "this" {
  count = var.dependabot_security_updates == null ? 0 : 1

  repository = github_repository.this.name
  enabled    = var.dependabot_security_updates
}

resource "github_branch_default" "this" {
  count = var.default_branch == null ? 0 : 1

  repository = github_repository.this.name
  branch     = var.default_branch
}

resource "github_repository_ruleset" "this" {
  for_each = var.rulesets

  name        = each.value.name
  repository  = github_repository.this.name
  target      = each.value.target
  enforcement = each.value.enforcement

  conditions {
    ref_name {
      include = sort(tolist(each.value.ref_name_include))
      exclude = sort(tolist(each.value.ref_name_exclude))
    }
  }

  dynamic "bypass_actors" {
    for_each = each.value.bypass_actors

    content {
      actor_id    = try(bypass_actors.value.actor_id, null)
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    creation                = try(each.value.rules.creation, null)
    update                  = try(each.value.rules.update, null)
    deletion                = try(each.value.rules.deletion, null)
    non_fast_forward        = try(each.value.rules.non_fast_forward, null)
    required_linear_history = try(each.value.rules.required_linear_history, null)
    required_signatures     = try(each.value.rules.required_signatures, null)

    dynamic "pull_request" {
      for_each = try(each.value.rules.pull_request, null) == null ? [] : [each.value.rules.pull_request]

      content {
        allowed_merge_methods             = sort(tolist(pull_request.value.allowed_merge_methods))
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_approving_review_count   = pull_request.value.required_approving_review_count
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
      }
    }

    dynamic "required_status_checks" {
      for_each = try(each.value.rules.required_status_checks, null) == null ? [] : [each.value.rules.required_status_checks]

      content {
        strict_required_status_checks_policy = required_status_checks.value.strict_required_status_checks_policy
        do_not_enforce_on_create             = required_status_checks.value.do_not_enforce_on_create

        dynamic "required_check" {
          for_each = required_status_checks.value.required_checks

          content {
            context        = required_check.value.context
            integration_id = try(required_check.value.integration_id, null)
          }
        }
      }
    }
  }
}
