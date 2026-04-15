output "account_onboarding_id" {
  description = "The ID of the account onboarding resource"
  value       = idsec_cce_aws_organization_account.add_account_to_org.id
}

output "deployed_services" {
  description = "List of CyberArk services deployed for this account"
  value       = local.services
}

output "sia_role_arn" {
  description = "The ARN of the SIA role, if enabled"
  value       = contains(local.services, "sia") ? module.sia[0].deployed_resources.main : null
}

output "sca_role_arn" {
  description = "The ARN of the SCA role, if enabled"
  value       = contains(local.services, "sca") ? module.sca[0].deployed_resources.main : null
}
