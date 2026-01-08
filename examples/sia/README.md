# SIA (Secure Infrastructure Access) Example

This example demonstrates how to deploy the CyberArk CCE Add Account module with SIA service.

## Overview

This example deploys the SIA (Secure Infrastructure Access) service module, which creates the necessary IAM roles and policies for CyberArk's Secure Infrastructure Access service.

## Prerequisites

1. AWS account with appropriate IAM permissions
2. Terraform >= 1.8.5
3. AWS Provider ~> 5.0

## Usage

1. Configure your AWS credentials:
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"
```

2. Create a `terraform.tfvars` file (optional):
```hcl
aws_region = "us-east-1"
```

3. Deploy:
```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

This example creates the following resources:
- IAM role for SIA cross-account access
- IAM policy with EC2 discovery and region scan permissions
- Role policy attachment

## Outputs

- `sia_role_arn`: The ARN of the IAM role that CyberArk SIA will assume for EC2 access

