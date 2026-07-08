output "deployed_resources" {
  description = "Map of deployed SCA resources including role ARN and SSO configuration"
  value       = { main = one(aws_iam_role.sca_cross_account_assume_role[*].arn), ssoEnable = var.sso_enable, ssoRegion = var.sso_region }
}

output "module_ready" {
  description = "List of all deployed resource identifiers to ensure dependencies"
  value = [
    one(aws_iam_role.sca_cross_account_assume_role[*].arn),
    one(aws_iam_policy.sca_cross_account_policy[*].arn),
    one(aws_iam_policy.sca_account_permissions_policy[*].arn),
    one(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_policy[*].id),
    one(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_account_permissions_policy[*].id),
  ]
}

