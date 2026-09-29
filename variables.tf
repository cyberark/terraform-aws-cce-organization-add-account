variable "org_onboarding_id" {
  description = "The AWS organization onboarding ID from the CCE create org output."
  type        = string
}

variable "services" {
  description = "A list of services to enable for this account (for example, [\"sia\", \"sca\"]). Note: 'sia' maps to 'dpa' service name."
  type        = list(string)
  default     = []
}

variable "role_name" {
  description = "The IAM role name prefix for SCA cross-account access. If null or empty, the organization's SCA role name is used as the default."
  type        = string
  default     = null
  nullable    = true
}
