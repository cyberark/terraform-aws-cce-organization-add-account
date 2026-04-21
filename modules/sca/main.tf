terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.7.5"
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # Extract org account ID and role name from the org onboarding ARN.
  org_account_id = regex("^arn:aws:iam::([0-9]{12}):role/.+$", var.sca_power_role_arn)[0]
  org_role_name  = regex("^arn:aws:iam::[0-9]{12}:role/(.+)$", var.sca_power_role_arn)[0]

  # Default naming uses the org account ID (the account that created the role).
  default_role_name = "CyberArkRoleSCA${local.org_account_id}-${var.tenant_id}"
  is_default_naming = local.org_role_name == local.default_role_name

  # Non-default naming is always <prefix>-<org_account_id>.
  custom_prefix = (
    local.is_default_naming ? null : regex(format("^(.+)-%s$", local.org_account_id), local.org_role_name)[0]
  )

  # Member-account role name must match what org onboarding references (org_role_name).
  sca_cross_account_iam_role_name = local.org_role_name


  # Use org_account_id to stay consistent with the role name (which comes from the org).
  sca_cross_account_managed_policy_name = (
    local.is_default_naming
    ? "CyberArkPolicyAccountForSCA${local.org_account_id}-${var.tenant_id}"
    : "${local.custom_prefix}${local.org_account_id}ForSCAPolicy"
  )
  sca_account_permissions_managed_policy_name = (
    local.is_default_naming
    ? "CyberarkIAMAccountPermissionsPolicyForSCA${local.org_account_id}-${var.tenant_id}"
    : "${local.custom_prefix}${local.org_account_id}ForSCAIAMPolicy"
  )
}

data "aws_iam_policy_document" "cyberark_sca_cross_account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.sca_service_account_id}:role/sca-provision-role-${var.sca_service_stage}"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.tenant_id}-${local.account_id}"]
    }
  }
}

data "aws_iam_policy_document" "cyberark_sca_cross_account_policy_document" {
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

data "aws_iam_policy_document" "cyberark_account_permissions_policy_document" {
  statement {
    sid    = "scapolicyaccountpermissions"
    effect = "Allow"
    actions = ["iam:UpdateAssumeRolePolicy",
      "iam:ListSAMLProviders",
      "iam:DeleteRolePolicy",
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

resource "aws_iam_role" "cyberark_sca_cross_account_assume_role" {
  count              = var.sso_enable == false ? 1 : 0
  name               = local.sca_cross_account_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.cyberark_sca_cross_account_assume_role_policy.json

  lifecycle {
    ignore_changes = [name]
  }
}

resource "aws_iam_policy" "cyberark_sca_cross_account_policy" {
  count       = var.sso_enable == false ? 1 : 0
  name        = local.sca_cross_account_managed_policy_name
  description = "The policy contains sca cross account permissions"
  policy      = data.aws_iam_policy_document.cyberark_sca_cross_account_policy_document.json
}

resource "aws_iam_policy" "cyberark_account_permissions_policy" {
  count       = var.sso_enable == false ? 1 : 0
  name        = local.sca_account_permissions_managed_policy_name
  description = "The policy contains sca IAM account permissions"
  policy      = data.aws_iam_policy_document.cyberark_account_permissions_policy_document.json
}

resource "aws_iam_role_policy_attachment" "cyberark_sca_cross_account_role_attached_to_policy" {
  count      = var.sso_enable == false ? 1 : 0
  role       = aws_iam_role.cyberark_sca_cross_account_assume_role[count.index].name
  policy_arn = aws_iam_policy.cyberark_sca_cross_account_policy[count.index].arn
}

resource "aws_iam_role_policy_attachment" "cyberark_sca_cross_account_role_attached_to_account_permissions_policy" {
  count      = var.sso_enable == false ? 1 : 0
  role       = aws_iam_role.cyberark_sca_cross_account_assume_role[count.index].name
  policy_arn = aws_iam_policy.cyberark_account_permissions_policy[count.index].arn
}
