# Example: Secrets Hub Account Onboarding

This example demonstrates how to onboard an AWS member account with Secrets Hub enabled.

## What This Example Does

* Onboards an AWS member account to CCE
* Enables **Secrets Hub** for the member account
* Creates IAM role for AWS Secrets Manager access in the member account
* Inherits Secrets Hub configuration (regions, settings) from the organization

## Prerequisites

1. **Identity Security Platform account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **AWS Requirements**
   - AWS organization with CCE organization module deployed on management account
   - Secrets Hub enabled in the organization configuration
   - Organization onboarding ID from the organization module output
   - AWS credentials for the member account with IAM permissions

3. **Terraform**
   - Terraform >= 1.7.5
   - AWS Provider ~> 5.0
   - Idsec Provider ~> 0.2.1

## What is Secrets Hub?

Secrets Hub provides centralized secrets management for an AWS account:

* **Centralized Management**: Manage secrets in this account from PAM vault
* **Automated Synchronization**: Push secrets from PAM to AWS Secrets Manager in this account
* **Lifecycle Management**: Create, update, rotate, and delete secrets from Secrets Hub
* **Inherited Configuration**: Uses the same region restrictions as configured in the organization
* **Audit & Compliance**: Complete audit trail of all secrets operations

## Resources Created

**IAM Role**: `CyberArk-Secrets-Hub-AllowSecretsAccessRole-{unique-suffix}`

**IAM Policy**: `CyberArk-Secrets-Hub-AllowSecretsAccessPolicy` with permissions to:
- Create secrets in configured regions (with required tags)
- List secrets in configured regions
- Update, delete, and manage tagged secrets
- Tag/untag secrets (limited to CyberArk-specific tags)
- Read secret values (only for secrets tagged with `CyberArk Extended Access: true`)

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
org_onboarding_id = "org-abc123"        # From organization module output
aws_region        = "us-east-1"
services          = ["secrets_hub"]     # Enable Secrets Hub service
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

1. **Query Organization Data**: The module queries the organization configuration to get Secrets Hub settings
2. **Validate Service**: Validates that Secrets Hub is enabled in the organization
3. **Provision Resources**: Creates IAM role and policy for Secrets Hub in this member account
4. **Register Account**: Registers the account with CCE and associates the Secrets Hub role
5. **Output Information**: Returns the role ARN and configuration details

## Secrets Management in This Account

### Creating Secrets

Secrets created by Secrets Hub in this account are automatically tagged with:
- `Sourced by Secrets Hub: ""` (empty value, required tag)

Only secrets with this tag can be managed by Secrets Hub.

### Extended Access

To allow Secrets Hub to read secret values (not just manage metadata), add the tag:
- `CyberArk Extended Access: true`

Without this tag, Secrets Hub can create, update, and delete secrets but cannot retrieve their values.

### Regional Restrictions

Secrets can only be created and managed in the AWS regions specified in the organization configuration. The member account inherits these regional restrictions from the management account setup.

## Security Considerations

### IAM Permissions

The Secrets Hub IAM policy follows the principle of least privilege:

* **CreateSecret**: Only allowed with the required `Sourced by CyberArk` tag in configured regions
* **ListSecrets**: Limited to configured regions
* **UpdateSecret, PutSecretValue, DeleteSecret**: Only for secrets with the `Sourced by CyberArk` tag
* **GetSecretValue**: Only for secrets tagged with both `Sourced by CyberArk` and `CyberArk Extended Access: true`
* **TagResource/UntagResource**: Limited to CyberArk-specific tags only

### External ID

The external ID for the trust relationship is automatically generated as `{tenant-id}-{account-id}` to prevent confused deputy attacks.

### Principal ARN

The IAM role trusts only the specific Secrets Hub global role ARN, not wildcard principals.

## Outputs

After successful deployment, the module outputs:

- `account_onboarding_id`: Unique onboarding identifier for this account
- `deployed_services`: List of services that were deployed (for example, `["secrets_hub"]`)
- `secrets_hub_role_arn`: Secrets Hub role ARN for this account

## Use Cases

### Scenario 1: Development Account

Enable Secrets Hub in a development account for testing secret synchronization:

```hcl
services = ["secrets_hub"]
```

### Scenario 2: Production Account with Multiple Services

Enable Secrets Hub alongside other services:

```hcl
services = ["sia", "sca", "secrets_hub"]
```

### Scenario 3: Dedicated Secrets Account

Use a dedicated AWS account solely for secrets management:

```hcl
services = ["secrets_hub"]
```

## Important Notes

- **Service Selection**: The `secrets_hub` service must be enabled in the organization configuration before you can enable it for member accounts.
- **Region Configuration**: The allowed AWS regions for secrets are inherited from the organization and cannot be changed at the account level.
- **Management Account**: This module should **NOT** be run on the AWS management account (use the organization module instead).
- **Idempotency**: It is safe to run this module multiple times. Resources will be updated as needed.

## Troubleshooting

**Issue**: Secrets Hub service not available

* **Solution**: Verify that Secrets Hub is enabled in the organization configuration on the management account

**Issue**: Cannot create secrets in a specific region

* **Solution**: Check that `secrets_manager_regions` configured in the organization module

**Issue**: Permission denied when managing secrets

* **Solution**: Verify the secret has the `Sourced by CyberArk` tag

**Issue**: Cannot read secret values

* **Solution**: Add the `CyberArk Extended Access: true` tag to the secret

## Cleanup

To remove all resources created by this module:

```bash
terraform destroy
```

**Warning**: This will remove the IAM role and unregister the account from Secrets Hub. Secrets stored in AWS Secrets Manager will remain but can no longer be managed in PAM.

## Next Steps

After successful deployment:

1. Verify the account appears in your CCE console with Secrets Hub enabled.
2. Configure secret synchronization in PAM for this account.
3. Create or sync secrets from PAM to this AWS account.
4. Test secret access from applications running in this account.
5. Set up secret rotation policies as needed.

## Additional Resources

* [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/)
* [Connect Cloud Environments Documentation](https://docs.cyberark.com/admin-space/latest/en/content/cce/cce-overview.htm)
