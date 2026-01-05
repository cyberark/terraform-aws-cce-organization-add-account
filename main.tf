terraform {
  required_version = ">= 1.7.5"
}

module "sia" {
  source                 = "./services_modules/sia"
  dpa_service_account_id = "123456789012"
  tenant_id              = "dummy-tenant-id"
}
