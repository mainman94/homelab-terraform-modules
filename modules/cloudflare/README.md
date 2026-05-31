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
  public_ip = "<your-public-ip>"

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
| `public_ip`                    | `string`                                                                                                           | `null`                                         | Public IPv4 address for A records. Required when `a_records` is not empty.      |
| `a_records`                    | `set(string)`                                                                                                      | `[]`                                           | Record names for A records. All point to `public_ip`.                           |
| `a_records_proxied`            | `bool`                                                                                                             | `true`                                         | Whether `a_records` are proxied by Cloudflare.                                  |
| `a_records_by_ip`              | `map(string)`                                                                                                      | `{}`                                           | Map of A record name to IPv4 address. Use when records need different IPs.      |
| `a_records_by_ip_proxied`      | `bool`                                                                                                             | `true`                                         | Whether `a_records_by_ip` records are proxied by Cloudflare.                    |
| `tunnel_id`                    | `string`                                                                                                           | `null`                                         | Cloudflare Tunnel ID used as the CNAME target prefix.                           |
| `cname_tunnel_records`         | `set(string)`                                                                                                      | `[]`                                           | Record names for tunnel-backed CNAME records.                                   |
| `cname_tunnel_records_proxied` | `bool`                                                                                                             | `true`                                         | Whether tunnel CNAME records are proxied.                                        |
| `cname_records`                | `map(string)`                                                                                                      | `{}`                                           | Map of CNAME name to target. Use for arbitrary CNAMEs (e.g. external services). |
| `cname_records_proxied`        | `bool`                                                                                                             | `false`                                        | Whether `cname_records` are proxied by Cloudflare.                              |
| `create_spf_record`            | `bool`                                                                                                             | `false`                                        | Whether to create an SPF TXT record.                                            |
| `spf_record_name`              | `string`                                                                                                           | `null`                                         | TXT record name for SPF. Defaults to `domain`.                                  |
| `spf_record_value`             | `string`                                                                                                           | `"v=spf1 include:_spf.mx.cloudflare.net ~all"` | TXT content for SPF. Do not include surrounding quotes.                         |
| `dkim_record_name`             | `string`                                                                                                           | `null`                                         | TXT record name for DKIM. Must be set together with `dkim_public_key`.          |
| `dkim_public_key`              | `string`                                                                                                           | `null`                                         | TXT value for the DKIM public key. Must be set together with `dkim_record_name`.|
| `email_routing_rules`          | `list(object({ name = string, local_part = string, destinations = set(string), priority = optional(number, 0) }))` | `[]`                                           | Email forwarding rules for `local_part@domain`. Names must be unique.           |

## Outputs

| Name                      | Description                                                     |
| ------------------------- | --------------------------------------------------------------- |
| `a_record_ids`            | Map of A record names to Cloudflare record IDs.                 |
| `a_records_by_ip_ids`     | Map of per-IP A record names to Cloudflare record IDs.          |
| `cname_record_ids`        | Map of arbitrary CNAME record names to Cloudflare record IDs.   |
| `cname_tunnel_record_ids` | Map of tunnel CNAME record names to Cloudflare record IDs.      |
| `spf_record_id`           | ID of the SPF TXT record, or `null` when disabled.              |
| `dkim_record_id`          | ID of the DKIM TXT record, or `null` when disabled.             |
| `email_routing_rule_ids`  | Map of email routing rule names to Cloudflare rule IDs.         |
