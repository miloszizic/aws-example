#!/bin/bash
# This script is run by the user-data script in the EC2 instance

# Install Cloudwatch agent
sudo yum install -y amazon-cloudwatch-agent

# Write the Cloudwatch agent configuration file
sudo cat >> /opt/aws/amazon-cloudwatch-agent/bin/config_temp.json <<EOF
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "messages",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "amazon-cloudwatch-agent.log",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/test.log",
            "log_group_name": "test.log",
            "log_stream_name": "{instance_id}",
            "timezone": "Local"
          }
        ]
      }
    },
    "log_stream_name": "ec2_test_log_stream_name",
    "force_flush_interval" : 15
  }
}
EOF
# Start the Cloudwatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config_temp.json -s
