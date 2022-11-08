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
data "aws_iam_policy_document" "autoscaling_trust_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
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
data "aws_ami" "selected" {
  owners      = ["self"]
  most_recent = true
  name_regex  = "poc-test-*"
  filter {
    name   = "state"
    values = ["available"]
  }
  # Filter by tag name
  filter {
    name   = "tag:Project"
    values = ["poc-test"]
  }
}
