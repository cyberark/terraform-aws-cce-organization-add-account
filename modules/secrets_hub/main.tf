terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.8.5"
}

data "aws_iam_policy_document" "secrets_hub_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:CreateSecret"]
    resources = ["arn:aws:secretsmanager:*:${var.account_id}:secret:*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Sourced by CyberArk"
      values   = [""]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:RequestedRegion"
      values   = var.secrets_manager_regions
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:ListSecrets"]
    resources = ["*"]

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:RequestedRegion"
      values   = var.secrets_manager_regions
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:UpdateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource"
    ]
    resources = ["arn:aws:secretsmanager:*:${var.account_id}:secret:*"]

    condition {
      test     = "StringEqualsIgnoreCase"
      variable = "aws:ResourceTag/Sourced by CyberArk"
      values   = [""]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:RequestedRegion"
      values   = var.secrets_manager_regions
    }
  }

  statement {
    sid    = "AllowTaggingIfExtendedAccess"
    effect = "Allow"

    actions = [
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource"
    ]

    resources = [
      "arn:aws:secretsmanager:*:${var.account_id}:secret:*"
    ]

    condition {
      test     = "ForAllValues:StringEqualsIgnoreCase"
      variable = "aws:TagKeys"
      values = [
        "Sourced by CyberArk",
        "CyberArk Extended Access"
      ]
    }

    condition {
      test     = "StringNotEqualsIgnoreCase"
      variable = "aws:ResourceTag/Sourced by CyberArk"
      values   = [""]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:RequestedRegion"
      values   = var.secrets_manager_regions
    }
  }

  statement {
    sid    = "AllowGetSecretIfExtendedAccess"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      "arn:aws:secretsmanager:*:${var.account_id}:secret:*"
    ]

    condition {
      test     = "StringEqualsIgnoreCase"
      variable = "aws:ResourceTag/CyberArk Extended Access"
      values   = ["true"]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "aws:RequestedRegion"
      values   = var.secrets_manager_regions
    }
  }
}

data "aws_iam_policy_document" "allow_secrets_access_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [split(":", var.cyberark_secrets_hub_role_arn)[4]]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [var.cyberark_secrets_hub_role_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        "${var.tenant_id}-${var.account_id}"
      ]
    }
  }
}

#############
# RESOURCES #
#############

resource "random_string" "role_suffix" {
  length  = 12
  special = false
  upper   = true
}

resource "aws_iam_role" "secrets_hub_role" {
  name               = "CyberArk-Secrets-Hub-AllowSecretsAccessRole-${random_string.role_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.allow_secrets_access_assume_role_policy.json
}

resource "aws_iam_policy" "secrets_hub_policy" {
  name        = "CyberArk-Secrets-Hub-AllowSecretsAccessPolicy"
  description = "Policy to allow scanning the ec2 instances"
  policy      = data.aws_iam_policy_document.secrets_hub_policy_document.json
}

resource "aws_iam_role_policy_attachment" "secrets_hub_attach" {
  role       = aws_iam_role.secrets_hub_role.name
  policy_arn = aws_iam_policy.secrets_hub_policy.arn
}