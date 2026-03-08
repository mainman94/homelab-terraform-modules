variable "bucket_name" {
  description = "Name of the Backblaze B2 bucket to create."
  type        = string
}

variable "bucket_type" {
  description = "B2 bucket visibility. Valid values are allPrivate and allPublic."
  type        = string
  default     = "allPrivate"

  validation {
    condition     = contains(["allPrivate", "allPublic"], var.bucket_type)
    error_message = "bucket_type must be either allPrivate or allPublic."
  }
}

variable "bucket_info" {
  description = "Optional metadata that should be stored on the bucket."
  type        = map(string)
  default     = {}
}

variable "default_server_side_encryption" {
  description = "Default server-side encryption settings for the bucket. Set to null to disable this block."
  type = object({
    algorithm = string
    mode      = string
  })
  default = {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket."
  type = list(object({
    file_name_prefix                                       = string
    days_from_hiding_to_deleting                           = optional(number)
    days_from_starting_to_canceling_unfinished_large_files = optional(number)
    days_from_uploading_to_hiding                          = optional(number)
  }))
  default = [
    {
      file_name_prefix                                       = ""
      days_from_hiding_to_deleting                           = 1
      days_from_starting_to_canceling_unfinished_large_files = 0
      days_from_uploading_to_hiding                          = 0
    }
  ]
}
