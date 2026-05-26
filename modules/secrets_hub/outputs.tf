output "deployed_resources" {
  description = "Map of deployed resource ARNs"
  value       = { main = aws_iam_role.secrets_hub_role.arn }
}

output "module_ready" {
  description = "List of resource identifiers indicating the module is ready"
  value = [
    aws_iam_role.secrets_hub_role.arn,
    aws_iam_policy.secrets_hub_policy.arn,
    aws_iam_role_policy_attachment.secrets_hub_attach.id,
  ]
}