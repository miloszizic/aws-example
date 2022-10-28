#
data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.github_federated_identity]
    }
  }
}

data "aws_iam_policy_document" "s3_github_policy" {
  statement {
    sid       = "AllowFullS3Access"
    actions   = ["s3:*"]
    resources = [module.lambda_s3.s3_bucket_arn, "${module.lambda_s3.s3_bucket_arn}/*"]
  }
}
