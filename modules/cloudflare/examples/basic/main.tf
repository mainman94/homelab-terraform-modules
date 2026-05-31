terraform {
  required_version = ">= 1.3.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

module "zone" {
  source = "../../"

  zone_id   = var.zone_id
  domain    = var.domain
  public_ip = var.public_ip

  a_records         = ["@", "www"]
  a_records_proxied = true

  tunnel_id            = var.tunnel_id
  cname_tunnel_records = ["app", "registry"]

  create_spf_record = true

  email_routing_rules = [
    {
      name         = "hello"
      local_part   = "hello"
      destinations = [var.destination_email]
      priority     = 10
    },
  ]
}

output "a_record_ids" {
  value = module.zone.a_record_ids
}

output "email_routing_rule_ids" {
  value = module.zone.email_routing_rule_ids
}
