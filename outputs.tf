################################################################################
# Outputs for VPC
################################################################################
output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = module.vpc.vpc_owner_id
}
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = module.vpc.private_subnet_arns
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = module.vpc.public_subnet_arns
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_ids
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "internet_gateway_id" {
  description = "The ARN of the Internet Gateway"
  value       = module.vpc.igw_arn
}

################################################################################
# Outputs for SG
################################################################################
output "public_web_security_group_arn" {
  description = "The ARN of the security group"
  value       = module.sg_web_public.security_group_arn
}

output "public_web-security_group_id" {
  description = "The ID of the security group"
  value       = module.sg_web_public.security_group_id
}
output "bastion_security_group_arn" {
  description = "The ARN of the security group"
  value       = module.bastion-sg[*].security_group_arn
}

output "bastion_security_group_id" {
  description = "The ID of the security group"
  value       = module.bastion-sg[*].security_group_id
}
output "bastion_ec2_name" {
  value = module.ec2_bastion_instance
}

output "security-group-backend-db-private_arn" {
  description = "The ARN of the security group"
  value       = module.sg_backend_db_private.security_group_arn
}

output "security-group-backend-db-private_id" {
  description = "The ID of the security group"
  value       = module.sg_backend_db_private.security_group_id
}
################################################################################
# Outputs for DB Master
################################################################################
output "db_master_instance_secret_string" {
  description = "The secret string of the DB Master instance"
  value       = data.aws_secretsmanager_secret_version.db_password.secret_string
  sensitive   = true
}
################################################################################
# Outputs for DB Replica
################################################################################

################################################################################
# Outputs for Internal ALB
################################################################################
output "alb_backend_private" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb_backend_private.lb_id
}

output "alb_backend_private_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb_backend_private.lb_arn
}

output "alb_backend_private_dns_name" {
  description = "The DNS name of the load balancer."
  value       = module.alb_backend_private.lb_dns_name
}

output "alb_backend_private_target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb_backend_private.target_group_arns
}

output "alb_backend_private_target_group_arns_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.alb_backend_private.target_group_arn_suffixes
}

output "alb_backend_private_target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.alb_backend_private.target_group_names
}

################################################################################
# Outputs for AWS roles
################################################################################

output "github_role_arn" {
  description = "The ARN of the role that GitHub needs to assume."
  value       = module.github_role.iam_role_arn
}
output "github_role_name" {
  value = module.github_role.iam_role_name
}
################################################################################
# Outputs for AWS S3 Lambda bucket
################################################################################
output "s3_lambda_bucket_id" {
  value = module.lambda_s3.s3_bucket_id
}
