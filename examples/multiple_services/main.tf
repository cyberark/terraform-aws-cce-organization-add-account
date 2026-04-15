terraform {
  required_version = ">= 1.8.5"

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
  region = var.aws_region
}

provider "idsec" {
  # Authentication configured via environment variables:
  # - IDSEC_TENANT_URL
  # - IDSEC_CLIENT_ID
  # - IDSEC_CLIENT_SECRET
}

module "cce_add_account" {
  source = "../../"

  org_onboarding_id = var.org_onboarding_id
  services          = var.services
}
