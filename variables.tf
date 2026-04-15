variable "org_onboarding_id" {
  description = "The AWS Organization Onboarding Id from the CCE create org output"
  type        = string
}

variable "services" {
  description = "List of services to enable for this account (e.g., [\"sia\", \"sca\"]). Note: 'sia' maps to 'dpa' service name."
  type        = list(string)
  default     = []
}

