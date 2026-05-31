variable "github_token" {
  description = "GitHub personal access token."
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
}

variable "repository_name" {
  description = "Name of the GitHub repository to create."
  type        = string
}
