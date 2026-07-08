terraform {
  required_version = ">= 1.7.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.2.1"
    }

  }
}

data "aws_caller_identity" "current" {}

data "idsec_cce_aws_tenant_service_details" "get_tenant_data" {}

data "idsec_cce_aws_organization" "get_org_onboarding_data" {
  id = var.org_onboarding_id
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  tenant_id  = data.idsec_cce_aws_tenant_service_details.get_tenant_data.tenant_id
  # Get services from organization data and normalize "dpa" to "sia"
  org_services_raw = data.idsec_cce_aws_organization.get_org_onboarding_data.services
  org_services     = [for service in local.org_services_raw : service == "dpa" ? "sia" : service]
  # Use user-provided services list
  services           = var.services
  parameters         = data.idsec_cce_aws_organization.get_org_onboarding_data.parameters
  sca_sso_enable     = try(tobool(tostring(local.parameters.sca.sso_enable)), false)
  sca_service_region = contains(var.services, "sca") ? data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.sca.service_region : null

  services_list = flatten([
    contains(var.services, "sia") ? [{
      service_name = "dpa"
      resources    = { DpaRoleArn = module.sia[0].deployed_resources.main }
    }] : [],

    contains(var.services, "sca") ? [{
      service_name = "sca"
      resources = {
        scaPowerRoleArn = local.sca_sso_enable ? local.parameters.sca.sca_power_role_arn : module.sca[0].deployed_resources.main
        ssoEnable       = tostring(local.sca_sso_enable)
        ssoRegion       = local.sca_sso_enable ? local.parameters.sca.sso_region : null
      }
    }] : [],

    contains(var.services, "secrets_hub") ? [{
      service_name = "secrets_hub"
      resources = {
        "SecretsHubCustomerAccessRole" = module.secrets_hub[0].deployed_resources.main,
        "SecretsHubGlobalRole"         = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.secrets_hub.global_role_arn

      }

    }] : []
  ])
}

# Validate that user-provided services match organization services
resource "terraform_data" "validate_services" {
  input = var.services

  lifecycle {
    precondition {
      condition     = length(var.services) > 0 && length(setintersection(toset(var.services), toset(local.org_services))) == length(var.services)
      error_message = <<-EOT
        ERROR: The services list must not be empty and must be a subset of the organization services.

        Provided services: ${length(var.services) > 0 ? join(", ", var.services) : "(empty)"}
        Organization services: ${join(", ", local.org_services)}

        Please provide at least one service that is configured in the organization.
      EOT
    }
    precondition {
      condition     = !contains(var.services, "sca") || local.sca_service_region != null
      error_message = <<-EOT
        ERROR: sca_service_region is required when sca is in services.
        Ensure SCA is activated and service region is available from tenant service details or org onboarding parameters.
      EOT
    }
    precondition {
      condition     = !local.sca_sso_enable || try(local.parameters.sca.sso_region, null) != null
      error_message = "sso_region is required when sso_enable is set to true on organization parameters."
    }
  }
}


module "sia" {
  depends_on = [terraform_data.validate_services]

  source                 = "./modules/sia"
  dpa_service_account_id = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.dpa.service_account_id
  tenant_id              = local.tenant_id
  count                  = contains(var.services, "sia") ? 1 : 0
}

module "sca" {
  depends_on = [terraform_data.validate_services]

  source                 = "./modules/sca"
  sca_service_stage      = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.sca.service_stage
  sca_service_account_id = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.sca.service_account_id
  sca_service_region     = local.sca_service_region
  tenant_id              = local.tenant_id
  sso_enable             = local.sca_sso_enable
  sso_region             = local.sca_sso_enable ? local.parameters.sca.sso_region : null
  sca_power_role_arn     = local.parameters.sca.sca_power_role_arn
  count                  = contains(var.services, "sca") ? 1 : 0
}

module "secrets_hub" {
  depends_on = [terraform_data.validate_services]

  source                        = "./modules/secrets_hub"
  cyberark_secrets_hub_role_arn = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.secrets_hub.global_role_arn
  secrets_manager_regions       = try(split(",", local.parameters.secrets_hub.secrets_manager_regions), local.parameters.secrets_hub.secrets_manager_regions)
  secrets_hub_origin_ip         = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.secrets_hub.origin_ip
  account_id                    = local.account_id
  tenant_id                     = local.tenant_id
  count                         = contains(local.services, "secrets_hub") ? 1 : 0
}

resource "idsec_cce_aws_organization_account" "add_account_to_org" {
  depends_on = [terraform_data.validate_services]

  parent_organization_id = var.org_onboarding_id
  account_id             = local.account_id

  parameters = data.idsec_cce_aws_organization.get_org_onboarding_data.parameters

  services = local.services_list


}
