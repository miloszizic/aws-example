################################################################################
# Data source for github role for actions
################################################################################
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
################################################################################
# Data source for the policy document for ASG log role
################################################################################
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
################################################################################
# Data Sources for database password from Secrets Manager
################################################################################
data "aws_secretsmanager_secret" "db_password" {
  depends_on = [aws_secretsmanager_secret_version.db_password]
  name       = aws_secretsmanager_secret.db_password.name
}
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}
################################################################################
# AMI selection for the EC2 instances in the ASG
################################################################################

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
################################################################################
# Select front-end instances from fronted autoscaling group for VPC reachability
# testing
################################################################################
data "aws_instances" "front-end" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-asg-instance-public"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
################################################################################
# Select backend instances from fronted autoscaling group
################################################################################
data "aws_instances" "back-end" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_name}-asg-instance-private"]
  }
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}
