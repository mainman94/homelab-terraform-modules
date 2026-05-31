# Requires Terraform >= 1.9 for mock_provider support and cross-variable validation.

mock_provider "cloudflare" {}

run "rejects_dkim_name_without_key" {
  command = plan

  variables {
    zone_id          = "abc123"
    domain           = "example.com"
    dkim_record_name = "cf2024._domainkey.example.com"
    dkim_public_key  = null
  }

  expect_failures = [var.dkim_record_name]
}

run "rejects_dkim_key_without_name" {
  command = plan

  variables {
    zone_id          = "abc123"
    domain           = "example.com"
    dkim_record_name = null
    dkim_public_key  = "v=DKIM1; k=rsa; p=abc123"
  }

  expect_failures = [var.dkim_record_name]
}

run "rejects_duplicate_email_rule_names" {
  command = plan

  variables {
    zone_id = "abc123"
    domain  = "example.com"
    email_routing_rules = [
      { name = "hello", local_part = "hello", destinations = ["a@example.com"] },
      { name = "hello", local_part = "hi", destinations = ["b@example.com"] },
    ]
  }

  expect_failures = [var.email_routing_rules]
}

run "accepts_a_records_by_ip" {
  command = plan

  variables {
    zone_id = "abc123"
    domain  = "example.com"
    a_records_by_ip = {
      "vpn"    = "10.0.0.1"
      "backup" = "10.0.0.2"
    }
  }
}

run "accepts_cname_records" {
  command = plan

  variables {
    zone_id = "abc123"
    domain  = "example.com"
    cname_records = {
      "mail"  = "mail.fastmail.com"
      "pages" = "alias.netlify.app"
    }
  }
}

run "accepts_valid_inputs" {
  command = plan

  variables {
    zone_id   = "abc123"
    domain    = "example.com"
    public_ip = "1.2.3.4"
    a_records = ["@"]
    email_routing_rules = [
      { name = "hello", local_part = "hello", destinations = ["a@example.com"] },
      { name = "info", local_part = "info", destinations = ["b@example.com"] },
    ]
  }
}

run "accepts_valid_dkim_pair" {
  command = plan

  variables {
    zone_id          = "abc123"
    domain           = "example.com"
    dkim_record_name = "cf2024._domainkey.example.com"
    dkim_public_key  = "v=DKIM1; k=rsa; p=abc123"
  }
}
