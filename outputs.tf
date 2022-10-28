#VPC
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

#Security Group
output "public_web_security_group_arn" {
  description = "The ARN of the security group"
  value       = module.sg_web_public.security_group_arn
}

output "public_web-security_group_id" {
  description = "The ID of the security group"
  value       = module.sg_web_public.security_group_id
}
#output "bastion_security_group_arn" {
#  description = "The ARN of the security group"
#  value       = module.bastion-sg.security_group_arn
#}
#
#output "bastion_security_group_id" {
#  description = "The ID of the security group"
#  value       = module.bastion-sg.security_group_id
#}
#output "bastion_ec2_name" {
#  value = module.ec2_bastion_instance
#}

output "security-group-backend-db-private_arn" {
  description = "The ARN of the security group"
  value       = module.sg_backend_db_private.security_group_arn
}

output "security-group-backend-db-private_id" {
  description = "The ID of the security group"
  value       = module.sg_backend_db_private.security_group_id
}

##DB Master
#output "db_instance_address-master" {
#  description = "The address of the RDS instance"
#  value       = module.db_master.db_instance_address
#}
#
#output "db_instance_arn-master" {
#  description = "The ARN of the RDS instance"
#  value       = module.db_master.db_instance_arn
#}
#
#output "db_instance_availability_zone-master" {
#  description = "The availability zone of the RDS instance"
#  value       = module.db_master.db_instance_availability_zone
#}
#
#output "db_instance_endpoint-master" {
#  description = "The connection endpoint"
#  value       = module.db_master.db_instance_endpoint
#}
#
#output "db_instance_engine-master" {
#  description = "The database engine"
#  value       = module.db_master.db_instance_engine
#}
#
#output "db_instance_engine_version_actual-master" {
#  description = "The running version of the database"
#  value       = module.db_master.db_instance_engine_version_actual
#}
#
#output "db_instance_id-master" {
#  description = "The RDS instance ID"
#  value       = module.db_master.db_instance_id
#}
#
#output "db_instance_resource_id-master" {
#  description = "The RDS Resource ID of this instance"
#  value       = module.db_master.db_instance_resource_id
#}
#
#output "db_instance_status-master" {
#  description = "The RDS instance status"
#  value       = module.db_master.db_instance_status
#}
#
#output "db_instance_name-master" {
#  description = "The database name"
#  value       = module.db_master.db_instance_name
#}
#
#output "db_instance_port-master" {
#  description = "The database port"
#  value       = module.db_master.db_instance_port
#}
#
#output "db_subnet_group_id-master" {
#  description = "The db subnet group name"
#  value       = module.db_master.db_subnet_group_id
#}
#
#output "db_subnet_group_arn-master" {
#  description = "The ARN of the db subnet group"
#  value       = module.db_master.db_subnet_group_arn
#}
#
#output "db_parameter_group_id-master" {
#  description = "The db parameter group id"
#  value       = module.db_master.db_parameter_group_id
#}
#
#output "db_parameter_group_arn-master" {
#  description = "The ARN of the db parameter group"
#  value       = module.db_master.db_parameter_group_arn
#}
#
##DB Replica
#output "db_instance_address-replica" {
#  description = "The address of the RDS instance"
#  value       = module.db_replica.db_instance_address
#}
#
#output "db_instance_arn-replica" {
#  description = "The ARN of the RDS instance"
#  value       = module.db_replica.db_instance_arn
#}
#
#output "db_instance_availability_zone-replica" {
#  description = "The availability zone of the RDS instance"
#  value       = module.db_replica.db_instance_availability_zone
#}
#
#output "db_instance_endpoint-replica" {
#  description = "The connection endpoint"
#  value       = module.db_replica.db_instance_endpoint
#}
#
#output "db_instance_engine-replica" {
#  description = "The database engine"
#  value       = module.db_replica.db_instance_engine
#}
#
#output "db_instance_engine_version_actual-replica" {
#  description = "The running version of the database"
#  value       = module.db_replica.db_instance_engine_version_actual
#}
#
#output "db_instance_id-replica" {
#  description = "The RDS instance ID"
#  value       = module.db_replica.db_instance_id
#}
#
#output "db_instance_resource_id-replica" {
#  description = "The RDS Resource ID of this instance"
#  value       = module.db_replica.db_instance_resource_id
#}
#
#output "db_instance_status-replica" {
#  description = "The RDS instance status"
#  value       = module.db_replica.db_instance_status
#}
#
#output "db_instance_name-replica" {
#  description = "The database name"
#  value       = module.db_replica.db_instance_name
#}
#output "db_instance_port-replica" {
#  description = "The database port"
#  value       = module.db_replica.db_instance_port
#}
#
#output "db_subnet_group_id-replica" {
#  description = "The db subnet group name"
#  value       = module.db_replica.db_subnet_group_id
#}
#
#output "db_subnet_group_arn-replica" {
#  description = "The ARN of the db subnet group"
#  value       = module.db_replica.db_subnet_group_arn
#}
#
#output "db_parameter_group_id-replica" {
#  description = "The db parameter group id"
#  value       = module.db_replica.db_parameter_group_id
#}
#
#output "db_parameter_group_arn-replica" {
#  description = "The ARN of the db parameter group"
#  value       = module.db_replica.db_parameter_group_arn
#}

output "alb_web_public_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb_web_public.lb_id
}

output "alb_web_public_arn" {
  description = "The ID and ARN of the load balancer we created."
  value       = module.alb_web_public.lb_arn
}

output "alb_web_public_dns" {
  description = "The DNS name of the load balancer."
  value       = module.alb_web_public.lb_dns_name
}

output "alb_web_public_target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb_web_public.target_group_arns
}

output "alb_web_public_target_group_arns_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = module.alb_web_public.target_group_arn_suffixes
}

output "alb_web_public_target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = module.alb_web_public.target_group_names
}

#Internal ALB
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
