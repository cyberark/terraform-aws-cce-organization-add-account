terraform {
  required_version = ">= 1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

resource "random_uuid" "suffix" {}

resource "aws_iam_role" "dpa_role" {
  name = "CyberArkSIA-${split("-", random_uuid.suffix.result)[0]}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.dpa_service_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.tenant_id
          }
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::${var.dpa_service_account_id}:role/DiscoveryServiceRole*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dpa_policy" {
  name        = "CyberarkJitAccountProvisioningPolicy-${split("-", var.tenant_id)[0]}-${split("-", random_uuid.suffix.result)[0]}"
  description = "Allows EC2 instance and region scan"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dpa_policy_attach" {
  role       = aws_iam_role.dpa_role.name
  policy_arn = aws_iam_policy.dpa_policy.arn
}
