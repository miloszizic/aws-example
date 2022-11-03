#
data "aws_iam_policy_document" "github_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "ForAllValues:StringLike"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAllValues:StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.github_federated_identity]
    }
  }
}

data "aws_secretsmanager_secret" "db_password" {
  depends_on = [aws_secretsmanager_secret_version.db_password]
  name       = "${var.env_name}-db-credentials-secret"
}
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}
