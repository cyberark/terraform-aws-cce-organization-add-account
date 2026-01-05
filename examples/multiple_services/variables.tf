variable "org_onboarding_id" {
  description = "The organization onboarding ID from the CCE organization module output"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

