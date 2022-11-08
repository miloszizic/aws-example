# Make custom IAM image with packer and ansible
# /opt/aws/amazon-cloudwatch-agent/bin/

# Define paker plugins
packer {
  required_plugins {
	amazon = {
	  version = ">= 1.0.0"
	  source  = "github.com/hashicorp/amazon"
	}
  }
}

# Define source AMI for packer to use
source "amazon-ebs" "amazon-linux-2-poc-ami" {
  ami_name      = "poc-test-${local.timestamp}"
  tags = var.tags
  source_ami_filter {
	filters = {
	  name                = "amzn2-ami-hvm-*-x86_64-gp2"
	  root-device-type    = "ebs"
	  virtualization-type = "hvm"
	}
	most_recent = true
	owners      = ["amazon"]
  }
  instance_type = var.instance_type
  region        = var.region
  ssh_username  = var.ssh_user
}
# Build AMI with packer
build {
  sources = [
	"source.amazon-ebs.amazon-linux-2-poc-ami"
  ]
  provisioner "file" {
	source = "config_temp.json"
	destination = "/tmp/config_temp.json"
  }
  provisioner "shell" {
	script = "./agent.sh"
  }
}
