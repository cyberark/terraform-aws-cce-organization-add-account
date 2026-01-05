output "sia_role_arn" {
  description = "The ARN of the SIA role"
  value       = module.sia.deployed_resources.main
}

