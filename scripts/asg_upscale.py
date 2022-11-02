# This script is used to upscale an ASG instances, there are not in use by Lambda at Default
# it can be used to scale up the ASG for a period of time

import boto3


def lambda_handler(event, context):
	asg = boto3.client('autoscaling')

	# Get all autoscaling groups with tag "Name: Poc" you can change this to any tag you want
	auto_scaling_groups = asg.describe_auto_scaling_groups()['AutoScalingGroups']
	print(auto_scaling_groups)
	for group in auto_scaling_groups:
		for tag in group['Tags']:
			if tag['Key'] == 'Name' and tag['Value'] == 'Poc':
				print(group['AutoScalingGroupName'])
				print(group['Instances'])
				# Scale up the ASG to desired capacity with MinSize, MaxSize and DesiredCapacity
				response = asg.update_auto_scaling_group(
					AutoScalingGroupName=group['AutoScalingGroupName'],
					MinSize=2,
					MaxSize=4,
					DesiredCapacity=2)
				print(f"ASG {group['AutoScalingGroupName']} scaled up to 2")
				print(response)
