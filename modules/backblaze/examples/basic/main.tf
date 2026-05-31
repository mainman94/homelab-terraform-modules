terraform {
  required_version = ">= 1.3.0"

  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "~> 0.12"
    }
  }
}

provider "b2" {}

module "bucket" {
  source = "../../"

  bucket_name = var.bucket_name

  bucket_info = {
    managed-by = "terraform"
  }

  lifecycle_rules = [
    {
      file_name_prefix                                       = ""
      days_from_hiding_to_deleting                           = 7
      days_from_starting_to_canceling_unfinished_large_files = 1
    }
  ]
}

output "bucket_id" {
  value = module.bucket.bucket_id
}

output "bucket_name" {
  value = module.bucket.bucket_name
}
