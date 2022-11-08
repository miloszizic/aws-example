#!/bin/bash
# This script is run by the user-data script in the EC2 instance

# Sleep for 30 sec to allow the instance to get ready
sleep 30
# Update the system
sudo yum update -y

# Install Cloudwatch agent
sudo yum install -y amazon-cloudwatch-agent

# Copy the config file from /tmp to /opt/aws/amazon-cloudwatch-agent/bin
sudo cp /tmp/config_temp.json /opt/aws/amazon-cloudwatch-agent/bin/config_temp.json

# Start the Cloudwatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config_temp.json -s
