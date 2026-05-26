variable "org_onboarding_id" {
  description = "The organization onboarding ID from the CCE organization module output"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the provider"
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "List of services to enable for this account. Must include 'secrets_hub' and match organization configuration."
  type        = list(string)
  default     = ["secrets_hub"]
}
