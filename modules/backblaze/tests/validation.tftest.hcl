# Requires Terraform >= 1.7 for mock_provider support.

mock_provider "b2" {}

run "rejects_invalid_bucket_type" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    bucket_type = "invalid"
  }

  expect_failures = [var.bucket_type]
}

run "rejects_invalid_sse_algorithm" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    default_server_side_encryption = {
      algorithm = "RSA"
      mode      = "SSE-B2"
    }
  }

  expect_failures = [var.default_server_side_encryption]
}

run "rejects_invalid_sse_mode" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    default_server_side_encryption = {
      algorithm = "AES256"
      mode      = "SSE-X"
    }
  }

  expect_failures = [var.default_server_side_encryption]
}

run "accepts_null_sse" {
  command = plan

  variables {
    bucket_name                    = "test-bucket"
    default_server_side_encryption = null
  }
}

run "accepts_valid_inputs" {
  command = plan

  variables {
    bucket_name = "test-bucket"
    bucket_type = "allPublic"
    default_server_side_encryption = {
      algorithm = "AES256"
      mode      = "SSE-B2"
    }
  }
}
