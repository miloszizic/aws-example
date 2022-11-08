# Define variables for agent.pkr.hcl


# Define local variable for timestamp and ami name
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "tags" {
  type = map(string)
  default = {
	"Environment" = "test"
	"Project" = "poc-test"
  }
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "ssh_user" {
  type = string
  default = "ec2-user"
}
