output "deployed_resources" {
  description = "a map of deployed SCA resources including role ARN and SSO configuration."
  value = {
    main                          = try(one(aws_iam_role.sca_cross_account_assume_role[*].arn), null)
    ssoEnable                     = tostring(var.sso_enable)
    ssoRegion                     = var.sso_region
    addPermissionsToManageCluster = var.add_permissions_to_manage_cluster
  }
}

output "module_ready" {
  description = "A list of all deployed resource identifiers to ensure dependencies."
  value = compact([
    try(one(aws_iam_role.sca_cross_account_assume_role[*].arn), null),
    try(one(aws_iam_policy.sca_cross_account_policy[*].arn), null),
    try(one(aws_iam_policy.sca_account_permissions_policy[*].arn), null),
    try(one(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_policy[*].id), null),
    try(one(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_account_permissions_policy[*].id), null),
    try(aws_iam_policy.sca_eks_cluster_permissions_policy[0].arn, null),
    try(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_eks_cluster_policy[0].id, null),
  ])
}
