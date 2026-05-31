variable "cloudflare_api_token" {
  description = "Cloudflare API token."
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Cloudflare zone ID."
  type        = string
}

variable "domain" {
  description = "Primary domain name."
  type        = string
}

variable "public_ip" {
  description = "Public IPv4 address for A records."
  type        = string
}

variable "tunnel_id" {
  description = "Cloudflare Tunnel ID for CNAME records."
  type        = string
}

variable "destination_email" {
  description = "Email address to forward to."
  type        = string
}
