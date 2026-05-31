output "repository_id" {
  description = "GitHub repository node ID."
  value       = github_repository.this.node_id
}

output "repository_name" {
  description = "GitHub repository name."
  value       = github_repository.this.name
}

output "repository_full_name" {
  description = "GitHub repository full name."
  value       = github_repository.this.full_name
}

output "repository_html_url" {
  description = "GitHub repository HTML URL."
  value       = github_repository.this.html_url
}

output "repository_default_branch" {
  description = "Managed default branch name, or null when not configured."
  value       = try(github_branch_default.this[0].branch, null)
}

output "ruleset_ids" {
  description = "Map of ruleset Terraform keys to GitHub ruleset node IDs."
  value       = { for k, r in github_repository_ruleset.this : k => r.node_id }
}
