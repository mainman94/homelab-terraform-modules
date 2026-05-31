variable "zone_id" {
  description = "Cloudflare zone ID where records and email routing rules are managed."
  type        = string
}

variable "domain" {
  description = "Primary domain name for the zone. Used for email routing matchers and default TXT record naming."
  type        = string
}

variable "public_ip" {
  description = "Public IPv4 address used for A records. Required when a_records is not empty."
  type        = string
  default     = null
  nullable    = true
}

variable "a_records" {
  description = "Set of A record names to create in the zone. Names are passed directly to Cloudflare."
  type        = set(string)
  default     = []
}

variable "a_records_proxied" {
  description = "Whether A records should be proxied by Cloudflare."
  type        = bool
  default     = true
}

variable "a_records_by_ip" {
  description = "Map of A record name to IPv4 address. Use when different records need different IPs."
  type        = map(string)
  default     = {}
}

variable "a_records_by_ip_proxied" {
  description = "Whether a_records_by_ip records should be proxied by Cloudflare."
  type        = bool
  default     = true
}

variable "tunnel_id" {
  description = "Cloudflare Tunnel ID used to build tunnel CNAME targets. Required when cname_tunnel_records is not empty."
  type        = string
  default     = null
  nullable    = true
}

variable "cname_tunnel_records" {
  description = "Set of CNAME record names that should point to the configured Cloudflare Tunnel."
  type        = set(string)
  default     = []
}

variable "cname_tunnel_records_proxied" {
  description = "Whether tunnel CNAME records should be proxied by Cloudflare."
  type        = bool
  default     = true
}

variable "cname_records" {
  description = "Map of CNAME record name to target hostname. Use for arbitrary CNAMEs not backed by a Cloudflare Tunnel."
  type        = map(string)
  default     = {}
}

variable "cname_records_proxied" {
  description = "Whether cname_records should be proxied by Cloudflare."
  type        = bool
  default     = false
}

variable "create_spf_record" {
  description = "Whether to create an SPF TXT record."
  type        = bool
  default     = false
}

variable "spf_record_name" {
  description = "TXT record name for the SPF record. Defaults to the configured domain when null."
  type        = string
  default     = null
  nullable    = true
}

variable "spf_record_value" {
  description = "TXT content for the SPF record. Do not include surrounding quotes; the provider handles quoting."
  type        = string
  default     = "v=spf1 include:_spf.mx.cloudflare.net ~all"
}

variable "dkim_record_name" {
  description = "TXT record name for the DKIM public key. When null, no DKIM record is created."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = (var.dkim_record_name == null) == (var.dkim_public_key == null)
    error_message = "dkim_record_name and dkim_public_key must both be set or both be null."
  }
}

variable "dkim_public_key" {
  description = "TXT value for the DKIM public key. Must be set together with dkim_record_name to create the record."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "email_routing_rules" {
  description = "Email forwarding rules keyed by rule name. Each rule forwards local_part@domain to one or more destinations."
  type = list(object({
    name         = string
    local_part   = string
    destinations = set(string)
    priority     = optional(number, 0)
  }))
  default = []

  validation {
    condition     = length(var.email_routing_rules) == length(distinct([for r in var.email_routing_rules : r.name]))
    error_message = "email_routing_rules names must be unique."
  }
}
