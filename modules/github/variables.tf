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

variable "default_branch" {
  description = "Default branch to enforce for the repository. Set to null to skip managing it."
  type        = string
  default     = null
  nullable    = true
}
