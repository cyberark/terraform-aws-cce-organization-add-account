terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.7.5"
}

data "aws_caller_identity" "current" {}

locals {
  account_id             = data.aws_caller_identity.current.account_id
  is_america_region      = contains(["us-east-1", "us-west-2"], var.sca_service_region)
  region_suffix          = local.is_america_region ? "" : "-${var.sca_service_region}"
  sca_provision_role_arn = "arn:aws:iam::${var.sca_service_account_id}:role/sca-provision-role-${var.sca_service_stage}${local.region_suffix}"

  # Extract org account ID and role name from the org onboarding ARN.
  org_account_id = regex("^arn:aws:iam::([0-9]{12}):role/.+$", var.sca_power_role_arn)[0]
  org_role_name  = regex("^arn:aws:iam::[0-9]{12}:role/(.+)$", var.sca_power_role_arn)[0]

  # Default naming uses the org account ID (the account that created the role).
  default_role_name = "SCARole-${local.org_account_id}-${var.tenant_id}"
  is_default_naming = local.org_role_name == local.default_role_name

  # Non-default naming is always <prefix>-<org_account_id>.
  custom_prefix = (
    local.is_default_naming ? null : regex(format("^(.+)-%s$", local.org_account_id), local.org_role_name)[0]
  )

  # Member-account role name must match what org onboarding references (org_role_name).
  sca_cross_account_iam_role_name = local.org_role_name


  # Policy names use the deployed member account ID, not the org management account ID.
  sca_cross_account_managed_policy_name = (
    local.is_default_naming
    ? "SCAPolicy-${local.account_id}-${var.tenant_id}"
    : "${local.custom_prefix}${local.account_id}ForSCAPolicy"
  )
  sca_account_permissions_managed_policy_name = (
    local.is_default_naming
    ? "SCAPermissionsPolicy-${local.account_id}-${var.tenant_id}"
    : "${local.custom_prefix}${local.account_id}ForSCAIAMPolicy"
  )
}

data "aws_iam_policy_document" "sca_cross_account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.sca_provision_role_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.tenant_id}-${local.account_id}"]
    }
  }
}

data "aws_iam_policy_document" "sca_cross_account_policy_document" {
  statement {
    sid       = "scapolicyallowtag"
    effect    = "Allow"
    actions   = ["sts:TagSession"]
    resources = ["*"]
  }

  statement {
    sid    = "AssumeCustomerRole"
    effect = "Allow"
    actions = ["sts:AssumeRole",
    "sts:SetSourceIdentity"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "sca_account_permissions_policy_document" {
  statement {
    sid    = "scapolicyaccountpermissions"
    effect = "Allow"
    actions = ["iam:UpdateAssumeRolePolicy",
      "iam:ListSAMLProviders",
      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:GetSAMLProvider",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:ListAttachedRolePolicies",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListRolePolicies",
    "iam:CreateSAMLProvider"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "sca_cross_account_assume_role" {
  count              = var.sso_enable == false ? 1 : 0
  name               = local.sca_cross_account_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.sca_cross_account_assume_role_policy.json

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_policy" "sca_cross_account_policy" {
  count       = var.sso_enable == false ? 1 : 0
  name        = local.sca_cross_account_managed_policy_name
  description = "The policy contains sca cross account permissions"
  policy      = data.aws_iam_policy_document.sca_cross_account_policy_document.json
}

resource "aws_iam_policy" "sca_account_permissions_policy" {
  count       = var.sso_enable == false ? 1 : 0
  name        = local.sca_account_permissions_managed_policy_name
  description = "The policy contains sca IAM account permissions"
  policy      = data.aws_iam_policy_document.sca_account_permissions_policy_document.json
}

resource "aws_iam_role_policy_attachment" "sca_cross_account_role_attached_to_policy" {
  count      = var.sso_enable == false ? 1 : 0
  role       = aws_iam_role.sca_cross_account_assume_role[count.index].name
  policy_arn = aws_iam_policy.sca_cross_account_policy[count.index].arn
}

resource "aws_iam_role_policy_attachment" "sca_cross_account_role_attached_to_account_permissions_policy" {
  count      = var.sso_enable == false ? 1 : 0
  role       = aws_iam_role.sca_cross_account_assume_role[count.index].name
  policy_arn = aws_iam_policy.sca_account_permissions_policy[count.index].arn
}
