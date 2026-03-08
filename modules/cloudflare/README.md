# Cloudflare Terraform Module

Terraform module for managing common Cloudflare zone resources such as A records, tunnel-backed CNAME records, SPF and DKIM TXT records, and email forwarding rules.

## Features

- Creates one or more `cloudflare_dns_record` A records
- Creates one or more tunnel-backed `cloudflare_dns_record` CNAME records
- Optionally creates SPF and DKIM TXT records
- Optionally creates `cloudflare_email_routing_rule` forwarding rules

## Requirements

```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}
```

Provider authentication is expected to be configured by the calling root module.

## Usage

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "cloudflare_zone" {
  source = "git::https://github.com/mainman94/homelab-terraform-modules.git//modules/cloudflare"

  zone_id   = var.cloudflare_zone_id
  domain    = "hauptmann.dev"
  public_ip = "84.115.110.237"

  a_records = [
    "hauptmann.dev",
    "*.hauptmann.dev",
  ]

  tunnel_id = var.cloudflare_tunnel_id
  cname_tunnel_records = [
    "registry",
  ]

  create_spf_record = true
  dkim_record_name  = "cf2024-1._domainkey.hauptmann.dev"
  dkim_public_key   = var.cloudflare_dkim_key

  email_routing_rules = [
    {
      name         = "hello"
      local_part   = "hello"
      destinations = [var.my_email]
    }
  ]
}
```

## Inputs

| Name                           | Type                                                                                                               | Default                                        | Description                                                            |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------- | ---------------------------------------------------------------------- |
| `zone_id`                      | `string`                                                                                                           | n/a                                            | Cloudflare zone ID where records and email routing rules are managed.  |
| `domain`                       | `string`                                                                                                           | n/a                                            | Primary domain used for email routing matchers and default TXT naming. |
| `public_ip`                    | `string`                                                                                                           | `null`                                         | Public IPv4 address used for A records.                                |
| `a_records`                    | `set(string)`                                                                                                      | `[]`                                           | Record names for A records.                                            |
| `a_records_proxied`            | `bool`                                                                                                             | `true`                                         | Whether A records are proxied by Cloudflare.                           |
| `tunnel_id`                    | `string`                                                                                                           | `null`                                         | Cloudflare Tunnel ID used as the CNAME target prefix.                  |
| `cname_tunnel_records`         | `set(string)`                                                                                                      | `[]`                                           | Record names for tunnel-backed CNAME records.                          |
| `cname_tunnel_records_proxied` | `bool`                                                                                                             | `true`                                         | Whether tunnel CNAME records are proxied.                              |
| `create_spf_record`            | `bool`                                                                                                             | `false`                                        | Whether to create an SPF TXT record.                                   |
| `spf_record_name`              | `string`                                                                                                           | `null`                                         | TXT record name for SPF. Defaults to `domain`.                         |
| `spf_record_value`             | `string`                                                                                                           | `"v=spf1 include:_spf.mx.cloudflare.net ~all"` | TXT content for SPF, including quoting if needed.                      |
| `dkim_record_name`             | `string`                                                                                                           | `null`                                         | TXT record name for DKIM.                                              |
| `dkim_public_key`              | `string`                                                                                                           | `null`                                         | TXT value for the DKIM public key.                                     |
| `email_routing_rules`          | `list(object({ name = string, local_part = string, destinations = set(string), priority = optional(number, 0) }))` | `[]`                                           | Email forwarding rules for `local_part@domain`.                        |

## Outputs

| Name                      | Description                                                |
| ------------------------- | ---------------------------------------------------------- |
| `a_record_ids`            | Map of A record names to Cloudflare record IDs.            |
| `cname_tunnel_record_ids` | Map of tunnel CNAME record names to Cloudflare record IDs. |
| `spf_record_id`           | ID of the SPF TXT record, or `null` when disabled.         |
| `dkim_record_id`          | ID of the DKIM TXT record, or `null` when disabled.        |
| `email_routing_rule_ids`  | Map of email routing rule names to Cloudflare rule IDs.    |
