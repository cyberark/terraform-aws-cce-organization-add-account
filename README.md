# CyberArk CCE AWS Organization Add Account Module

A Terraform module for deploying CyberArk's Secure Infrastructure Access (SIA) service on AWS accounts.

## Overview

This module provisions the necessary IAM roles and policies for CyberArk's Secure Infrastructure Access (SIA) service, enabling secure access to EC2 instances with just-in-time access and automated discovery.

## Features

- **SIA Service Deployment**: Creates IAM roles and policies for Secure Infrastructure Access
- **EC2 Discovery**: Enables automated discovery of EC2 resources across regions
- **Just-in-Time Access**: Provides secure, on-demand access to EC2 instances
- **Idempotent Operations**: Safe to run multiple times
- **Simple Configuration**: Minimal setup required

## Prerequisites

Before using this module, ensure you have:

1. **AWS Requirements**
   - AWS account with appropriate IAM permissions
   - Ability to create IAM roles and policies

2. **Terraform Requirements**
   - Terraform >= 1.7.5
   - AWS Provider ~> 5.0

## Usage

### Basic Example

```hcl
terraform {
  required_version = ">= 1.7.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "cce_add_account_sia" {
  source = "cyberark/cce-organization-add-account/aws"
}

output "sia_role_arn" {
  value = module.cce_add_account_sia.sia_role_arn
}
```

## Examples

A complete working example is available in the [`examples/sia/`](examples/sia/) directory, which demonstrates how to deploy the SIA service module.

## Inputs

This module currently uses placeholder values and does not require any input variables.

## Outputs

| Name | Description |
|------|-------------|
| `sia_role_arn` | ARN of the SIA IAM role |

## Service Details

### SIA (Secure Infrastructure Access)

Enables secure access to EC2 instances with:
- Just-in-time access to EC2 instances
- Automated discovery of EC2 resources
- Session recording and monitoring

**Resources Created:**
- IAM role: `CyberArkDynamicPrivilegedAccess-{tenant-id-prefix}`
- IAM policy: `CyberarkJitAccountProvisioningPolicy-{tenant-id-prefix}`

## How It Works

1. **Provision Resources**: Creates IAM role and policy for SIA cross-account access
2. **Configure Permissions**: Sets up EC2 discovery and region scan permissions
3. **Output Information**: Returns the IAM role ARN for reference

## Important Notes

- **Idempotency**: The module is safe to run multiple times and will update resources as needed
- **Regional Deployment**: Deploy this module in the same region as your primary AWS operations
- **Placeholder Values**: The module currently uses placeholder values for tenant ID and service account ID

## Documentation

For more information:
- [CyberArk Identity Security Platform Documentation](https://docs.cyberark.com/)

## Licensing

This repository is subject to the following licenses:
- **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf)
- **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE.txt](LICENSE.txt))

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About

CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).
