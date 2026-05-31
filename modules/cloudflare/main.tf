locals {
  email_routing_rules = {
    for rule in var.email_routing_rules : rule.name => rule
  }

  spf_record_name = coalesce(var.spf_record_name, var.domain)
}

resource "cloudflare_dns_record" "a_records" {
  for_each = var.a_records

  zone_id = var.zone_id
  name    = each.key
  content = var.public_ip
  type    = "A"
  ttl     = 1
  proxied = var.a_records_proxied

  lifecycle {
    precondition {
      condition     = var.public_ip != null
      error_message = "public_ip must be set when a_records is not empty."
    }
  }
}

resource "cloudflare_dns_record" "a_records_by_ip" {
  for_each = var.a_records_by_ip

  zone_id = var.zone_id
  name    = each.key
  content = each.value
  type    = "A"
  ttl     = 1
  proxied = var.a_records_by_ip_proxied
}

resource "cloudflare_dns_record" "cname_records" {
  for_each = var.cname_records

  zone_id = var.zone_id
  name    = each.key
  content = each.value
  type    = "CNAME"
  ttl     = 1
  proxied = var.cname_records_proxied
}

resource "cloudflare_dns_record" "cname_tunnel_records" {
  for_each = var.cname_tunnel_records

  zone_id = var.zone_id
  name    = each.key
  content = "${var.tunnel_id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = var.cname_tunnel_records_proxied

  lifecycle {
    precondition {
      condition     = var.tunnel_id != null
      error_message = "tunnel_id must be set when cname_tunnel_records is not empty."
    }
  }
}

resource "cloudflare_dns_record" "txt_spf" {
  count = var.create_spf_record ? 1 : 0

  zone_id = var.zone_id
  name    = local.spf_record_name
  type    = "TXT"
  content = var.spf_record_value
  ttl     = 1
}

resource "cloudflare_dns_record" "txt_dkim" {
  count = var.dkim_record_name != null && var.dkim_public_key != null ? 1 : 0

  zone_id = var.zone_id
  name    = var.dkim_record_name
  type    = "TXT"
  content = var.dkim_public_key
  ttl     = 1
}

resource "cloudflare_email_routing_rule" "forwarding_rules" {
  for_each = local.email_routing_rules

  name     = each.value.name
  zone_id  = var.zone_id
  priority = each.value.priority
  matchers = [
    {
      type  = "literal"
      field = "to"
      value = "${each.value.local_part}@${var.domain}"
    }
  ]

  actions = [
    {
      type  = "forward"
      value = sort(tolist(each.value.destinations))
    }
  ]
}
