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

  lifecycle {
    ignore_changes = [
      archive_on_destroy,
      ignore_vulnerability_alerts_during_read,
    ]
  }
}

resource "github_branch_default" "this" {
  count = var.default_branch == null ? 0 : 1

  repository = github_repository.this.name
  branch     = var.default_branch
}
