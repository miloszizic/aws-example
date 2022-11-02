# This script is used to shut down an ASG instances, there are not in use by Lambda at Default
# it can be used to stop the instances in the ASG for a period of time

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
				# Scale down the ASG to 0
				response = asg.update_auto_scaling_group(
					AutoScalingGroupName=group['AutoScalingGroupName'],
					MinSize=0,
					MaxSize=0,
					DesiredCapacity=0)
				print(f"ASG {group['AutoScalingGroupName']} scaled down to 0")
				print(response)
