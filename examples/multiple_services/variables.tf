variable "org_onboarding_id" {
  description = "The AWS organization onboarding ID from the CCE create org output."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where resources are deployed."
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "A list of services to enable for this account (for example, [\"sia\", \"sca\"])"
  type        = list(string)
  default     = ["sia", "sca"]
}

variable "role_name" {
  description = "The SCA IAM role name prefix. This should match the sca.role_name variable in the terraform-aws-cce-organization module."
  type        = string
  default     = null
}
