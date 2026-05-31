output "bucket_id" {
  description = "Backblaze B2 bucket ID."
  value       = b2_bucket.this.bucket_id
}

output "bucket_name" {
  description = "Backblaze B2 bucket name."
  value       = b2_bucket.this.bucket_name
}
