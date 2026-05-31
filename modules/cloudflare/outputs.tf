output "a_record_ids" {
  description = "Map of A record names to Cloudflare record IDs."
  value = {
    for name, record in cloudflare_dns_record.a_records : name => record.id
  }
}

output "a_records_by_ip_ids" {
  description = "Map of per-IP A record names to Cloudflare record IDs."
  value = {
    for name, record in cloudflare_dns_record.a_records_by_ip : name => record.id
  }
}

output "cname_record_ids" {
  description = "Map of arbitrary CNAME record names to Cloudflare record IDs."
  value = {
    for name, record in cloudflare_dns_record.cname_records : name => record.id
  }
}

output "cname_tunnel_record_ids" {
  description = "Map of tunnel CNAME record names to Cloudflare record IDs."
  value = {
    for name, record in cloudflare_dns_record.cname_tunnel_records : name => record.id
  }
}

output "spf_record_id" {
  description = "Cloudflare record ID of the SPF TXT record, or null when disabled."
  value       = try(cloudflare_dns_record.txt_spf[0].id, null)
}

output "dkim_record_id" {
  description = "Cloudflare record ID of the DKIM TXT record, or null when disabled."
  value       = try(cloudflare_dns_record.txt_dkim[0].id, null)
}

output "email_routing_rule_ids" {
  description = "Map of email routing rule names to Cloudflare rule IDs."
  value = {
    for name, rule in cloudflare_email_routing_rule.forwarding_rules : name => rule.id
  }
}
