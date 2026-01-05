output "account_onboarding_id" {
  description = "The ID of the account onboarding resource"
  value       = module.cce_add_account.account_onboarding_id
}

output "deployed_services" {
  description = "List of CyberArk services deployed for this account"
  value       = module.cce_add_account.deployed_services
}

output "sia_role_arn" {
  description = "ARN of the SIA IAM role if enabled"
  value       = module.cce_add_account.sia_role_arn
}

output "sca_role_arn" {
  description = "ARN of the SCA IAM role if enabled"
  value       = module.cce_add_account.sca_role_arn
}

output "secrets_hub_role_arn" {
  description = "ARN of the Secrets Hub IAM role if enabled"
  value       = module.cce_add_account.secrets_hub_role_arn
}

