# Local values
locals {
  # Tags
  backup_tags = {
    Name                = "poc"
    Backup              = "true"
    Terraform           = "true"
    Environment         = var.env_name
    BackupRetentionDays = "7"
  }
  general_tags = {
    Terraform   = "true"
    Environment = var.env_name
  }

  # DB local values

  engine               = "mysql"
  engine_version       = "8.0.27"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
}
variable "bucket_name" {
  type = string
}
variable "key" {
  type = string
}
variable "profile" {
  type = string
}
#VPC CIDR
variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  description = "vpc cidr block"
  type        = string
}
#Env naming
variable "env_name" {
  default = "poc"
  type    = string
}
#Availability Zone
variable "az1" {
  default     = "us-west-1a"
  description = "Availability Zone (us-west-1a)"
  type        = string
}

variable "az2" {
  default     = "us-west-1b"
  description = "Availability Zone (us-west-1b)"
  type        = string
}

variable "az3" {
  default     = "us-west-1c"
  description = "Availability Zone (us-west-1c)"
  type        = string
}

#Public SubNet
variable "public-subnet1-cidr" {
  default     = "10.0.1.0/24"
  description = "Public Subnet 1 CIDR block"
  type        = string
}

variable "public-subnet2-cidr" {
  default     = "10.0.2.0/24"
  description = "Public Subnet 2 CIDR block"
  type        = string
}

#Private SubNet
variable "private-subnet1-cidr" {
  default     = "10.0.3.0/24"
  description = "Private Subnet 1 CIDR block"
  type        = string
}

variable "private-subnet2-cidr" {
  default     = "10.0.4.0/24"
  description = "Private Subnet 2 CIDR block"
  type        = string
}

#AMI
variable "ami" {
  default     = "ami-0e4d9ed95865f3b40"
  description = "AMI"
  type        = string
}

#Instance Type
variable "instance_type" {
  default     = "t2.micro"
  description = "instance_type"
  type        = string
}

variable "key_pair" {
  type        = string
  description = "Key pair name"
}

# Region
variable "region" {
  default     = "us-west-1"
  description = "Region"
  type        = string
}

variable "go_backup_filename" {
  default = "ec2_backup"
  type    = string
}
variable "py_cleanup_filename" {
  default = "ec2_cleanup"
  type    = string
}
variable "github_repo" {
  default = ""
  type    = string
}

variable "lambda_s3_name" {
  default = "s3-lambda-20221018154517921000000002"
  type    = string
}
variable "github_federated_identity" {
  default = ""
  type    = string
}
variable "create_db" {
  default = false
  type    = bool
}
variable "create_db_replica" {
  default = false
  type    = bool
}
variable "enable_rds_secret_rotation" {
  default = false
  type    = bool
}
variable "create_bastion" {
  default = false
  type    = bool
}
variable "email_endpoint" {
  default = ""
  type    = string
}
