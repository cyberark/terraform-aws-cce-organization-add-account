variable "org_onboarding_id" {
  description = "The AWS Organization Onboarding Id from the CCE create org output"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "services" {
  description = "List of services to enable for this account (e.g., [\"sia\", \"sca\"])"
  type        = list(string)
  default     = ["sia", "sca"]
}

variable "role_name" {
  description = "The SCA IAM role name prefix. Should match the sca.role_name variable in the terraform-aws-cce-organization module."
  type        = string
  default     = null
}
