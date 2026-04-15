# CCE AWS Organization Add Account Onboarding Module

This Terraform module onboards AWS member accounts to Connect Cloud Environments (CCE) with CyberArk SaaS services.
CCE helps customers easily adopt CyberArk services and establish secure trust relationships with their AWS environments.

## Overview

This module is designed to be run on **AWS member accounts** after the [CCE organization module](https://github.com/cyberark/terraform-aws-cce-organization) has been deployed to the AWS management account. It automatically provisions the necessary IAM roles and policies for services based on the organization configuration.

## Features

- **Conditional Resource Provisioning**: Only creates resources for services enabled in the organization
- **Multiple Service Support**: 
  - **SCA (Secure Cloud Access)**: Just-in-time privileged access management with optional SSO integration
  - **SIA (Secure Infrastructure Access)**: EC2 instance discovery and secure access
- **Idempotent Operations**: Safe to run multiple times
- **Standardized Outputs**: Provides ARNs and IDs for all created resources

## Prerequisites

Before using this module, ensure that you have the following information and requirements:

1. **CyberArk Identity Security Platform Account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **AWS Requirements**
   - An AWS organization
   - CCE organization module deployed on the management account
   - Organization onboarding ID from the organization module output
   - Appropriate AWS credentials with IAM permissions on the member account

3. **Terraform Requirements**
   - Terraform >= 1.7.5
   - AWS Provider ~> 5.0
   - CyberArk idsec Provider ~> 0.1

## Usage

### Basic Example

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.2.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "idsec" {
  # Configure with your CyberArk tenant credentials
  # See: https://registry.terraform.io/providers/cyberark/idsec/latest/docs
}

module "cce_add_account" {
  source = "cyberark/cce-organization-add-account/aws"

  org_onboarding_id = "org-abc123"  # From organization module output
}
```

## Examples

A complete working example is available in the [`examples/multiple_services/`](examples/multiple_services/) directory, which demonstrates how to onboard an AWS member account with all services that are enabled in your organization's configuration.

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `org_onboarding_id` | The organization onboarding ID from the CCE organization module output | `string` | Yes |
| `services` | List of services to enable for this account (for example, `["sia", "sca"]`). Must match services configured in the organization. | `list(string)` | No (defaults to organization services) |

## Outputs

| Name | Description |
|------|-------------|
| `account_onboarding_id` | The unique identifier for this account onboarding |
| `deployed_services` | List of services deployed for this account |
| `sia_role_arn` | The SIA role ARN, if enabled (null otherwise) |
| `sca_role_arn` | The SCA role ARN, if enabled (null otherwise) |

## Service Details

### SCA (Secure Cloud Access)

Provides just-in-time privileged access to cloud resources with:
- Dynamic privilege elevation
- Session monitoring and recording
- Role-based access control
- Optional AWS IAM Identity Center (SSO) integration

**Resources Created:**
- IAM role: `CyberArkRoleSCA-{account-id}`
- IAM policy: `CyberArkPolicyAccountForSCA-{account-id}`
- Conditional SSO policy (if SSO is enabled)

### SIA (Secure Infrastructure Access)

Enables secure access to EC2 instances with:
- Just-in-time access to EC2 instances
- Automated discovery of EC2 resources
- Session recording and monitoring

**Resources Created:**
- IAM role: `CyberArkSIA-{unique-suffix}`
- IAM policy: `CyberarkJitAccountProvisioningPolicy-{tenant-id-prefix}-{unique-suffix}`

## How It Works

1. **Query Organization Data**: The module queries the CCE organization configuration using the provided `org_onboarding_id`
2. **Validate Services**: Validates that the services you provide match those configured in the organization
3. **Provision Resources**: Conditionally creates IAM roles and policies for each specified service
4. **Register Account**: Registers the account with CCE, providing the ARNs of created resources
5. **Output Information**: Returns resource ARNs and configuration details

## Module Deletion

**⚠️ Understanding Module Deletion**

When you delete this module, it's important to understand what gets removed:

**What Gets Deleted from AWS**:
* IAM roles and policies created by this module
* The account resources from your AWS environment

**What remains in CCE**:
The account registration remains on the CCE platform. The account is **NOT** removed from CCE when you delete this module. The account will only be fully removed from CCE when the entire organization is deleted using the `terraform-aws-cce-organization` module on the management account.

**How to delete this module**:

Remove this module from your main.tf file or run `terraform destroy` to remove AWS resources. The account remains registered on CCE until the organization is deleted.

**Important**: You must first delete all the accounts in the organization before you delete the organization's management account using the `terraform-aws-cce-organization` module. This ensures a clean and complete removal of all resources from both AWS and CCE.

## Important Notes

- **Service Selection**: You must provide the `services` variable with the list of services to enable (for example, `["sia", "sca"]`). These services must match those configured in the organization on the management account.
- **Management Account**: This module should **NOT** be run on the AWS management account. Use the CCE organization module on the management account instead.
- **Idempotency**: The module is safe to run multiple times and will update resources as needed.
- **Regional Deployment**: Deploy this module in the same region as your primary AWS operations.

## Documentation

For more information:
- [Connect Cloud Environments](https://docs.cyberark.com/admin-space/latest/en/content/cce/cce-overview.htm).
- [CyberArk Identity Security Platform Documentation](https://docs.cyberark.com/)
- [CyberArk Terraform Provider](https://registry.terraform.io/providers/cyberark/idsec/latest/docs)

## Licensing

This repository is subject to the following licenses:
- **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf)
- **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE))

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About

CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).