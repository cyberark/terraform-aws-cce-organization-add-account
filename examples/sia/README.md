# SIA (Secure Infrastructure Access) Example

This example demonstrates how to deploy the CyberArk CCE Add Account module with only the SIA service.

## Overview

This example deploys the SIA (Secure Infrastructure Access) service module, which creates the necessary IAM roles and policies for CyberArk's Secure Infrastructure Access service.

## Prerequisites

1. **CyberArk Identity Security Platform account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **AWS Requirements**
   - AWS organization with CCE organization module deployed on management account
   - Organization onboarding ID from the organization module output
   - Appropriate AWS credentials with IAM permissions on the member account

3. **Terraform**
   - Terraform >= 1.8.5
   - AWS Provider ~> 5.0
   - CyberArk idsec Provider 0.2.0-dd80a1

## Usage

### Step 1: Configure Environment Variables

Set the following environment variables for authentication:

```bash
export IDSEC_TENANT_URL="https://your-tenant.id.cyberark.cloud"
export IDSEC_CLIENT_ID="your-client-id"
export IDSEC_CLIENT_SECRET="your-client-secret"
export AWS_REGION="us-east-1"
```

### Step 2: Create terraform.tfvars

Create a `terraform.tfvars` file with your configuration:

```hcl
org_onboarding_id = "org-abc123"  # From organization module output
aws_region        = "us-east-1"
```

### Step 3: Deploy

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

This example creates the following resources:
- IAM role: `CyberArkDynamicPrivilegedAccess-{tenant-id-prefix}`
- IAM policy: `CyberarkJitAccountProvisioningPolicy-{tenant-id-prefix}`
- Account registration with CCE organization

## Outputs

- `sia_role_arn`: The ARN of the IAM role that CyberArk SIA will assume for EC2 access

## Important Notes

- This example only deploys the SIA service. To deploy multiple services, see the `multiple_services` example.
- The SIA service must be enabled in your organization configuration (set on the management account).

