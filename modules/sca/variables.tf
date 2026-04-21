variable "sca_service_stage" {
  description = "The SCA Service stage to deploy the resources"
  type        = string
}

variable "sca_service_account_id" {
  description = "The AWS account number for SCA account"
  type        = string
}

variable "tenant_id" {
  description = "The tenant id of deployer"
  type        = string
}

variable "sso_enable" {
  description = "AWS IAM Identity Center"
  type        = bool
  default     = false
}

variable "sso_region" {
  description = "AWS IAM Identity Center Region"
  type        = string
  default     = "us-east-1"
}

variable "sca_power_role_arn" {
  description = "parameters.sca.sca_power_role_arn from org onboarding. IAM role name = segment after :role/ in this ARN."
  type        = string
}

