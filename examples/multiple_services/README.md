# CyberArk CCE Add Account Example

This example demonstrates how to onboard an AWS member account to CyberArk's Connect Cloud Environments (CCE) services.

## Overview

This example will provision resources for all CyberArk services that are enabled in your organization configuration. The module automatically detects which services were configured when you ran the CCE organization module on your management account and deploys the appropriate resources.

## Supported Services

The module automatically detects and deploys resources for the following services:

### SCA (Secure Cloud Access)
Just-in-time privileged access management with:
- Dynamic privilege elevation
- Session monitoring and recording
- Role-based access control
- Optional AWS IAM Identity Center (SSO) integration

**Resources Created:**
- IAM role: `CyberArkRoleSCATerraform-{account-id}`
- IAM policy: `CyberArkPolicyAccountForSCATerraform-{account-id}`
- Conditional SSO policy (if SSO is enabled)

### SIA (Secure Infrastructure Access)
EC2 instance discovery and secure access with:
- Just-in-time access to EC2 instances
- Automated discovery of EC2 resources
- Session recording and monitoring

**Resources Created:**
- IAM role: `CyberArkDynamicPrivilegedAccess-{tenant-id-prefix}`
- IAM policy: `CyberarkJitAccountProvisioningPolicy-{tenant-id-prefix}`

### Secrets Hub
Centralized AWS Secrets Manager integration with:
- Visibility and governance of AWS secrets
- Synchronization with CyberArk Privilege Cloud
- Policy-based access control
- Multi-region support

**Resources Created:**
- IAM role: `CyberArk-Secrets-Hub-AllowSecretsAccessRole-{random-suffix}`
- IAM policy: `CyberArk-Secrets-Hub-AllowSecretsAccessPolicy-{random-suffix}`

## Prerequisites

1. **CyberArk Identity Security Platform account**
   - Active subscription with CCE services enabled
   - API credentials (client ID and secret)
   - Tenant URL

2. **AWS Requirements**
   - AWS Organization with CCE organization module deployed on management account
   - Organization onboarding ID from the organization module output
   - Appropriate AWS credentials with IAM permissions on the member account

3. **Terraform**
   - Terraform >= 1.8.5
   - AWS Provider ~> 5.0
   - CyberArk idsec Provider ~> 0.1

## Usage

### Step 1: Configure Environment Variables

Set the following environment variables for CyberArk authentication:

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
# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Apply the configuration
terraform apply
```

## How It Works

1. **Query Organization Data**: The module queries the CCE organization configuration using the provided `org_onboarding_id`
2. **Detect Enabled Services**: Automatically determines which services are enabled in the organization
3. **Provision Resources**: Conditionally creates IAM roles and policies for each enabled service
4. **Register Account**: Registers the account with CyberArk, providing the ARNs of created resources
5. **Output Information**: Returns the onboarding ID, deployed services, and resource ARNs

## Outputs

After successful deployment, the module outputs:

- `account_onboarding_id`: Unique identifier for this account onboarding
- `deployed_services`: List of services that were deployed (e.g., `["sca", "sia", "secrets_hub"]`)
- `sia_role_arn`: ARN of SIA role (null if not enabled)
- `sca_role_arn`: ARN of SCA role (null if not enabled)
- `secrets_hub_role_arn`: ARN of Secrets Hub role (null if not enabled)

## Important Notes

- **Service Selection**: You cannot enable/disable individual services at the account level. Services are determined by the organization configuration set on the management account.
- **Management Account**: This module should **NOT** be run on the AWS management account.
- **Idempotency**: The module is safe to run multiple times and will update resources as needed.
- **Regional Deployment**: Deploy this module in the same region as your primary AWS operations.

## Cleanup

To remove all resources created by this module:

```bash
terraform destroy
```

**Warning**: This will remove the IAM roles and unregister the account from CyberArk services.

