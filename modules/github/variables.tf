variable "name" {
  description = "Repository name."
  type        = string
}

variable "description" {
  description = "Repository description. Set to null to leave it unset."
  type        = string
  default     = null
  nullable    = true
}

variable "homepage_url" {
  description = "Repository homepage URL. Set to null to leave it unset."
  type        = string
  default     = null
  nullable    = true
}

variable "visibility" {
  description = "Repository visibility."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be one of: public, private, internal."
  }
}

variable "topics" {
  description = "Repository topics."
  type        = set(string)
  default     = []
}

variable "has_issues" {
  description = "Whether issues are enabled for the repository."
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Whether projects are enabled for the repository."
  type        = bool
  default     = false
}

variable "has_wiki" {
  description = "Whether the wiki is enabled for the repository."
  type        = bool
  default     = false
}

variable "allow_merge_commit" {
  description = "Whether merge commits are allowed. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "allow_squash_merge" {
  description = "Whether squash merges are allowed. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "allow_rebase_merge" {
  description = "Whether rebase merges are allowed. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "allow_auto_merge" {
  description = "Whether auto-merge is allowed. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "delete_branch_on_merge" {
  description = "Whether merged branches should be deleted automatically. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "allow_update_branch" {
  description = "Whether pull requests can be updated with the base branch from the UI. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "allow_forking" {
  description = "Whether the repository can be forked. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "archived" {
  description = "Whether the repository is archived."
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "Archive the repository instead of deleting it on terraform destroy."
  type        = bool
  default     = true
}

variable "vulnerability_alerts" {
  description = "Whether Dependabot vulnerability alerts are enabled. Null leaves the provider default behavior unchanged."
  type        = bool
  default     = null
  nullable    = true
}

variable "secret_scanning" {
  description = "Whether secret scanning is enabled. Null leaves the repository's current setting untouched. Not available on private repositories without GitHub Advanced Security."
  type        = bool
  default     = null
  nullable    = true
}

variable "secret_scanning_push_protection" {
  description = "Whether secret scanning push protection is enabled. Null leaves the repository's current setting untouched."
  type        = bool
  default     = null
  nullable    = true
}

variable "default_branch" {
  description = "Default branch to enforce for the repository. Set to null to skip managing it."
  type        = string
  default     = null
  nullable    = true
}

variable "rulesets" {
  description = "Repository rulesets keyed by a stable Terraform identifier. Currently only branch rulesets are supported by this module wrapper."
  type = map(object({
    name             = string
    target           = optional(string, "branch")
    enforcement      = optional(string, "active")
    ref_name_include = optional(set(string), ["~DEFAULT_BRANCH"])
    ref_name_exclude = optional(set(string), [])
    bypass_actors = optional(list(object({
      actor_id    = optional(number)
      actor_type  = string
      bypass_mode = optional(string, "always")
    })), [])
    rules = object({
      creation                = optional(bool)
      update                  = optional(bool)
      deletion                = optional(bool)
      non_fast_forward        = optional(bool)
      required_linear_history = optional(bool)
      required_signatures     = optional(bool)
      pull_request = optional(object({
        allowed_merge_methods             = optional(set(string), ["merge", "squash", "rebase"])
        dismiss_stale_reviews_on_push     = optional(bool, false)
        require_code_owner_review         = optional(bool, false)
        require_last_push_approval        = optional(bool, false)
        required_approving_review_count   = optional(number, 0)
        required_review_thread_resolution = optional(bool, false)
      }))
      required_status_checks = optional(object({
        strict_required_status_checks_policy = optional(bool, false)
        do_not_enforce_on_create             = optional(bool, false)
        required_checks = set(object({
          context        = string
          integration_id = optional(number)
        }))
      }))
    })
  }))
  default = {}

  validation {
    condition = alltrue([
      for ruleset in values(var.rulesets) : contains(["branch"], ruleset.target)
    ])
    error_message = "rulesets currently support only the branch target in this module wrapper."
  }

  validation {
    condition = alltrue([
      for ruleset in values(var.rulesets) : contains(["active", "disabled", "evaluate"], ruleset.enforcement)
    ])
    error_message = "ruleset enforcement must be one of: active, disabled, evaluate."
  }

  validation {
    condition = alltrue(flatten([
      for ruleset in values(var.rulesets) : ruleset.rules.pull_request == null ? [true] : [
        ruleset.rules.pull_request.required_approving_review_count >= 0 &&
        ruleset.rules.pull_request.required_approving_review_count <= 6
      ]
    ]))
    error_message = "ruleset pull request approval count must be between 0 and 6."
  }

  validation {
    condition = alltrue(flatten([
      for ruleset in values(var.rulesets) : ruleset.rules.pull_request == null ? [true] : [
        length(setsubtract(ruleset.rules.pull_request.allowed_merge_methods, toset(["merge", "squash", "rebase"]))) == 0
      ]
    ]))
    error_message = "ruleset allowed_merge_methods may only contain merge, squash, or rebase."
  }

  validation {
    condition = alltrue(flatten([
      for ruleset in values(var.rulesets) : [
        for actor in ruleset.bypass_actors : contains(
          ["RepositoryRole", "Team", "Integration", "OrganizationAdmin"],
          actor.actor_type
        )
      ]
    ]))
    error_message = "bypass_actors actor_type must be one of: RepositoryRole, Team, Integration, OrganizationAdmin."
  }
}
