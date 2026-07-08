variable "cyberark_secrets_hub_role_arn" {
  description = "The Secrets Hub global role ARN taken from the Settings page in UI or via /api/configuration API"
  type        = string
}

variable "secrets_manager_regions" {
  description = "Region list to allow Secrets creation in"
  type        = list(string)
}

variable "account_id" {
  description = "The AWS account ID to deploy on"
  type        = string
}

variable "tenant_id" {
  description = "The ID of the CyberArk tenant that hosts Secrets Hub (About > Tenant details > ID)"
  type        = string
}

variable "secrets_hub_origin_ip" {
  description = "Comma-separated list of Secrets Hub egress IPs allowed to assume the access role. Sourced from the CyberArk tenant service details."
  type        = string
}