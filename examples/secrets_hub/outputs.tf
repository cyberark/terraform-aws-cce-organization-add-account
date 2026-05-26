output "account_onboarding_id" {
  description = "The unique identifier for this account onboarding"
  value       = module.cce_add_account.account_onboarding_id
}

output "deployed_services" {
  description = "List of services deployed for this account"
  value       = module.cce_add_account.deployed_services
}

output "secrets_hub_role_arn" {
  description = "The Secrets Hub role ARN for this account"
  value       = module.cce_add_account.secrets_hub_role_arn
}
