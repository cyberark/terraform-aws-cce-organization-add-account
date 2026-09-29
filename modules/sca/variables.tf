variable "sca_service_stage" {
  description = "The SCA Service stage to deploy the resources."
  type        = string
}

variable "sca_service_region" {
  description = "The SCA Service region to deploy the resources."
  type        = string
}

variable "sca_service_account_id" {
  description = "The AWS account number for SCA account."
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID from where the resources are deployed."
  type        = string

  validation {
    condition     = length(var.tenant_id) <= 43
    error_message = "tenant_id must be at most 43 characters so default SCARole-{account_id}-{tenant_id} IAM role names stay within the 64-character AWS limit."
  }
}

variable "sso_enable" {
  description = "AWS IAM Identity Center."
  type        = bool
  default     = false
}

variable "sso_region" {
  description = "AWS IAM Identity Center region."
  type        = string
  default     = "us-east-1"
}

variable "sca_power_role_arn" {
  description = "parameters.sca.sca_power_role_arn from org onboarding. IAM role name = segment after :role/ in this ARN."
  type        = string
}

variable "custom_role_name" {
  description = "The SCA IAM role name prefix, matching the sca.role_name from the organization module. If null or empty, role and policy names are derived from sca_power_role_arn or module defaults."
  type        = string
  default     = null
  nullable    = true
}

variable "add_permissions_to_manage_cluster" {
  description = "When true, attaches EKS cluster management permissions to the member-account SCA role."
  type        = bool
  default     = false
}