resource "b2_bucket" "homelab_backup_bucket" {

  bucket_name = var.bucket_name
  bucket_type = var.bucket_type
  bucket_info = var.bucket_info

  dynamic "default_server_side_encryption" {
    for_each = var.default_server_side_encryption == null ? [] : [var.default_server_side_encryption]
    content {
      algorithm = default_server_side_encryption.value.algorithm
      mode      = default_server_side_encryption.value.mode
    }
  }

  dynamic "lifecycle_rules" {
    for_each = var.lifecycle_rules
    content {
      file_name_prefix                                       = lifecycle_rules.value.file_name_prefix
      days_from_hiding_to_deleting                           = try(lifecycle_rules.value.days_from_hiding_to_deleting, null)
      days_from_starting_to_canceling_unfinished_large_files = try(lifecycle_rules.value.days_from_starting_to_canceling_unfinished_large_files, null)
      days_from_uploading_to_hiding                          = try(lifecycle_rules.value.days_from_uploading_to_hiding, null)
    }
  }

}
