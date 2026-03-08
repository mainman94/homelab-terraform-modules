# Backblaze B2 Terraform Module

Terraform module for creating a Backblaze B2 bucket with optional default encryption and lifecycle rules.

## Features

- Creates one `b2_bucket`
- Configures default server-side encryption
- Supports configurable lifecycle rules

## Requirements

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = ">= 0.12.1"
    }
  }
}
```

Provider authentication is expected through the provider block or the environment variables `B2_APPLICATION_KEY_ID` and `B2_APPLICATION_KEY`.

## Usage

```hcl
provider "b2" {}

module "backblaze_bucket" {
  source = "git::https://github.com/mainman94/homelab-terraform-modules.git//modules/backblaze"

  bucket_name = "homelab-backups"
  bucket_type = "allPrivate"
  bucket_info = {
    managed-by = "terraform"
    workload   = "homelab"
  }
}
```

## Inputs

| Name                             | Type                                            | Default                                     | Description                                     |
| -------------------------------- | ----------------------------------------------- | ------------------------------------------- | ----------------------------------------------- |
| `bucket_name`                    | `string`                                        | n/a                                         | Name of the Backblaze B2 bucket to create.      |
| `bucket_type`                    | `string`                                        | `"allPrivate"`                              | Bucket visibility. `allPrivate` or `allPublic`. |
| `bucket_info`                    | `map(string)`                                   | `{}`                                        | Optional metadata stored on the bucket.         |
| `default_server_side_encryption` | `object({ algorithm = string, mode = string })` | `{ algorithm = "AES256", mode = "SSE-B2" }` | Default server-side encryption for the bucket.  |
| `lifecycle_rules`                | `list(object(...))`                             | See module default                          | Lifecycle rules applied to the bucket.          |

### `lifecycle_rules` object

| Attribute                                                | Type     | Default | Description                                            |
| -------------------------------------------------------- | -------- | ------- | ------------------------------------------------------ |
| `file_name_prefix`                                       | `string` | n/a     | Restrict the lifecycle rule to files with this prefix. |
| `days_from_hiding_to_deleting`                           | `number` | `null`  | Days from hiding a file version until deletion.        |
| `days_from_starting_to_canceling_unfinished_large_files` | `number` | `null`  | Days until unfinished large files are canceled.        |
| `days_from_uploading_to_hiding`                          | `number` | `null`  | Days from upload until hiding a file version.          |

## Outputs

This module currently does not define Terraform outputs.

## Example

The usage example above reflects the current module interface.
