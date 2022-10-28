#### VPC Module ####
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.env_name}-vpc"
  cidr = var.vpc-cidr

  azs             = [var.az1, var.az2]
  public_subnets  = [var.private-subnet1-cidr, var.private-subnet2-cidr]
  private_subnets = [var.public-subnet1-cidr, var.public-subnet2-cidr]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  create_igw = true

  tags = local.general_tags
}
module "github_role" {
  source                   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  create_role              = true
  role_name                = "github-role-s3"
  custom_role_trust_policy = data.aws_iam_policy_document.github_trust_policy.json
  custom_role_policy_arns  = [module.github_s3_policy.arn]

}
module "github_s3_policy" {
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name          = "github-s3-policy"
  create_policy = true
  policy        = data.aws_iam_policy_document.s3_github_policy.json
}
### S3 bucket for lambda storing ###
module "lambda_s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket                  = "s3-lambda-20221018154517921000000002"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  versioning = {
    enabled = true
  }

  tags = local.general_tags
}


#### Bastian Security group Module ####
#module "bastion-sg" {
#  source = "terraform-aws-modules/security-group/aws"
#
#  name                = "${var.env_name}-bastiansg"
#  description         = "Security group for web app"
#  depends_on          = [module.vpc]
#  vpc_id              = module.vpc.vpc_id
#  ingress_cidr_blocks = ["0.0.0.0/0"]
#  ingress_rules       = ["ssh-tcp"]
#  egress_rules        = ["all-all"]
#  tags = local.general_tags
#
#}
#### EC2-Instance Module ####
#module "ec2_bastion_instance" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "~> 4.0"
#
#  name = "${var.env_name}-bastion-host"
#
#  ami                    = var.ami
#  instance_type          = var.instance_type
#  vpc_security_group_ids = [module.bastion-sg.security_group_id]
#  subnet_id              = element(module.vpc.public_subnets, 0)
#  key_name               = var.key_pair
#
#  tags = local.general_tags
#}
module "sg_web_public" {
  source       = "terraform-aws-modules/security-group/aws"
  egress_rules = ["all-all"]


  name                = "${var.env_name}-websg"
  description         = "Security group for frontend app"
  depends_on          = [module.vpc]
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]

}

#### DB Security group Module ####
module "sg_backend_db_private" {
  source = "terraform-aws-modules/security-group/aws"

  name                = "${var.env_name}-dbsg"
  description         = "Security group for backend and DB"
  depends_on          = [module.vpc]
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["ssh-tcp", "mysql-tcp", "postgresql-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}

#### public ALB Module ####
# Health check is needed for the ALB to work properly
module "alb_web_public" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.env_name}-alb-web-public"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.sg_web_public.security_group_id]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "${var.env_name}-alb-web-public"
  }
}

#### private ALB Module ####
module "alb_backend_private" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.env_name}-alb-private"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  security_groups = [module.sg_backend_db_private.security_group_id]
  #If true, ELB will be an internal ELB
  internal = true

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  tags = local.general_tags
}
### public ASG module ###
module "asg_web_public" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name              = "${var.env_name}-asg-public"
  use_name_prefix   = false
  instance_name     = "${var.env_name}-asg-instance-public"
  min_size          = 2
  max_size          = 4
  desired_capacity  = 2
  health_check_type = "EC2"
  # A list of subnet IDs to launch resources in.
  vpc_zone_identifier = module.vpc.private_subnets
  tags                = local.backup_tags

  initial_lifecycle_hooks = [
    {
      name                 = "DeploymentWaitHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "hello" = "started" })
    },
    {
      name                 = "TerminationWaitHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "goodbye" = "done" })
    }
  ]

  # Launch template
  launch_template_name        = "${var.env_name}-launch-template"
  launch_template_description = "Complete launch template example"
  image_id                    = var.ami
  instance_type               = var.instance_type
  user_data                   = base64encode(local.user_data_internal)
  # ARNs, for use with Application or Network Load Balancing
  target_group_arns = module.alb_web_public.target_group_arns
  # A list of security group IDs to associate with.
  security_groups = [module.sg_web_public.security_group_id]

  # Target scaling policy schedule based on average CPU load
  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 1200
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
    predictive-scaling = {
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        mode                         = "ForecastAndScale"
        scheduling_buffer_time       = 10
        max_capacity_breach_behavior = "IncreaseMaxCapacity"
        max_capacity_buffer          = 10
        metric_specification = {
          target_value = 45
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label         = "PocLabel"
          }
          predefined_load_metric_specification = {
            predefined_metric_type = "ASGTotalCPUUtilization"
            resource_label         = "PocLabel"
          }
        }
      }
    }
    request-count-per-target = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 120
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label         = "${module.alb_web_public.lb_arn_suffix}/${module.alb_web_public.target_group_arn_suffixes[0]}"
        }
        target_value = 800
      }
    }
  }
}

#### private ASG module ###
module "asg_backend_private" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name                = "${var.env_name}-asg-private"
  use_name_prefix     = false
  instance_name       = "${var.env_name}-asg-instance-private"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  health_check_type   = "EC2"
  vpc_zone_identifier = module.vpc.private_subnets
  tags                = local.backup_tags

  initial_lifecycle_hooks = [
    {
      name                 = "DeploymentWaitHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 60
      lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "hello" = "started" })
    },
    {
      name                 = "TerminationWaitHook"
      default_result       = "CONTINUE"
      heartbeat_timeout    = 180
      lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
      # This could be a rendered data resource
      notification_metadata = jsonencode({ "goodbye" = "done" })
    }
  ]

  # Launch template
  launch_template_name        = "${var.env_name}-launch-template"
  launch_template_description = "Complete launch template example"
  image_id                    = var.ami
  instance_type               = var.instance_type
  target_group_arns           = module.alb_backend_private.target_group_arns
  security_groups             = [module.sg_backend_db_private.security_group_id]

  # Target scaling policy schedule based on average CPU load
  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 1200
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
    predictive-scaling = {
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        mode                         = "ForecastAndScale"
        scheduling_buffer_time       = 10
        max_capacity_breach_behavior = "IncreaseMaxCapacity"
        max_capacity_buffer          = 10
        metric_specification = {
          target_value = 32
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
            resource_label         = "testLabel"
          }
          predefined_load_metric_specification = {
            predefined_metric_type = "ASGTotalCPUUtilization"
            resource_label         = "testLabel"
          }
        }
      }
    }
    request-count-per-target = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 120
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ALBRequestCountPerTarget"
          resource_label         = "${module.alb_backend_private.lb_arn_suffix}/${module.alb_backend_private.target_group_arn_suffixes[0]}"
        }
        target_value = 800
      }
    }
  }
}
### DB module ###
#module "db_master" {
#  source = "terraform-aws-modules/rds/aws"
#
#  identifier             = "${var.env_name}-master"
#  subnet_ids             = module.vpc.private_subnets
#  vpc_security_group_ids = [module.sg_backend_db_private.security_group_id]
#  engine                 = local.engine
#  engine_version         = local.engine_version
#  major_engine_version   = local.major_engine_version
#  family                 = local.family         #DB parameter group
#  instance_class         = local.instance_class #DB option group
#  create_db_subnet_group = true                 #DB subnet group
#
#  allocated_storage       = local.allocated_storage
#  backup_retention_period = 1 #Backups are required in order to create a replica
#  skip_final_snapshot     = true
#  deletion_protection     = false
#
#  db_name  = "masterdb"
#  username = "poc"
#  password = "POCDBpocdb"
#  tags     = local.general_tags
#
#}
#
#### Replicate DB module ###
#module "db_replica" {
#  source = "terraform-aws-modules/rds/aws"
#
#  identifier             = "${var.env_name}-replica"
#  replicate_source_db    = module.db_master.db_instance_id
#  engine                 = local.engine
#  major_engine_version   = local.major_engine_version
#  family                 = local.family         #DB parameter group
#  instance_class         = local.instance_class #DB option group
#  allocated_storage      = local.allocated_storage
#  deletion_protection    = false
#  skip_final_snapshot    = true
#  subnet_ids             = module.vpc.private_subnets
#  vpc_security_group_ids = [module.sg_backend_db_private.security_group_id]
#  tags                   = local.general_tags
#}

# Lambda module for EC2 instances backups in VPC
#
module "lambda_ec2_backup" {
  source     = "terraform-aws-modules/lambda/aws"

  function_name  = "backup_ec2_lambda"
  create_package = false
  description = "Lambda function for EC2 instances backups"
  handler                  = "scripts/${var.go_backup_filename}"
  store_on_s3              = true
  role_name                = "lambda_ami_backup_role"
  runtime                  = "go1.x"
  timeout                  = 600
  attach_policy_statements = true
  s3_existing_package = {
	bucket = module.lambda_s3.s3_bucket_id
	key    = "scripts/${var.go_backup_filename}.zip"
  }

  policy_statements = {
    ec2backup = {
      effect = "Allow"
      actions = [
        "ec2:CreateImage",
        "ec2:CreateTags",
        "ec2:DescribeSnapshots",
        "ec2:DeleteSnapshot",
        "ec2:DeregisterImage",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
      ]
      resources = ["*"]
    }
  }

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    ScanAmiRule = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["lambda-backup"]
    }
  }
  tags = local.general_tags
}

module "lambda_ec2_cleanup" {
  source = "terraform-aws-modules/lambda/aws"

  function_name  = "cleanup_ec2_lambda"
  description    = "Lambda function for EC2 instances cleanup of"
  handler        = "${var.py_cleanup_filename}.lambda_handler"
  lambda_role    = module.lambda_ec2_backup.lambda_role_arn
  create_package = false
  create_role    = false
  runtime        = "python3.9"
  timeout        = 600
  store_on_s3 = true
  s3_existing_package = {
	bucket = module.lambda_s3.s3_bucket_id
	key    = "scripts/${var.py_cleanup_filename}.zip"
  }

  create_current_version_allowed_triggers = false
  allowed_triggers = {
    ScanAmiRule = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["lambda-cleanup"]
    }
  }
  tags = local.general_tags
}

# Make event-bridge rule to trigger lambda function every day at 10:00 UTC
module "eventbridge" {
  source     = "terraform-aws-modules/eventbridge/aws"
  create_bus = false
  rules = {
    lambda-backup = {
      description         = "Cron expression to trigger lambda function for ec2 instances backup"
      schedule_expression = "cron(0 10 * * ? *)" # every day at 10:00 UTC
    },
    lambda-cleanup = {
      description         = "Cron expression to trigger lambda function for ec2 instances backup cleanup"
      schedule_expression = "cron(0 11 * * ? *)" # every day at 11:00 UTC
    }
  }

  targets = {
    lambda-backup = [
      {
        name = "lambda-backup-cron"
        arn  = module.lambda_ec2_backup.lambda_function_arn
      }
    ]
    lambda-cleanup = [
      {
        name = "lambda-clean-cron"
        arn  = module.lambda_ec2_cleanup.lambda_function_arn
      }
    ]
  }
}

#resource "null_resource" "lambda_go_build" {
#  triggers = {
#	build = sha1(file("scripts/${var.go_backup_filename}.go"))
#  }
#
#  provisioner "local-exec" {
#	command = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o scripts/${var.go_backup_filename} scripts/${var.go_backup_filename}.go"
#  }
#  provisioner "local-exec" {
#	command = "zip scripts/${var.go_backup_filename}.zip scripts/${var.go_backup_filename}"
#  }
#  provisioner "local-exec" {
#	command = "zip scripts/${var.py_cleanup_filename}.zip scripts/${var.py_cleanup_filename}.py"
#  }
#}
#
#
#resource "null_resource" "upload_to_s3" {
#  depends_on = [null_resource.lambda_go_build]
#  provisioner "local-exec" {
#	command = "aws s3 cp scripts/${var.go_backup_filename}.zip s3://${module.lambda_s3.s3_bucket_id}/scripts/${var.go_backup_filename}.zip"
#  }
#  provisioner "local-exec" {
#	command = "aws s3 cp scripts/${var.py_cleanup_filename}.zip s3://${module.lambda_s3.s3_bucket_id}/scripts/${var.py_cleanup_filename}.zip"
#  }
#}
