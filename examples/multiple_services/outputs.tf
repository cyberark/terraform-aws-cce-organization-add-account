output "account_onboarding_id" {
  description = "The account onboarding resource ID."
  value       = module.cce_add_account.account_onboarding_id
}

output "deployed_services" {
  description = "A list of Idira services deployed for this account."
  value       = module.cce_add_account.deployed_services
}

output "sia_role_arn" {
  description = "ARN of the SIA IAM role if enabled"
  value       = module.cce_add_account.sia_role_arn
}

output "sca_role_arn" {
  description = "The IAM role ARN for Secure Cloud Access, if enabled."
  value       = module.cce_add_account.sca_role_arn
}
