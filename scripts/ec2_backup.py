# # Automated EC2 backup script, that makes an instance image with AS Lambda.
# # It targets all instances with a tag "Backup: True"

import collections
import pprint

import boto3
import datetime

ec = boto3.client('ec2')


# Get ec2 client
def lambda_handler(event, context):
	reservations = ec.describe_instances(Filters=[
		{
			'Name': 'tag:Name', 'Values': ['Poc']
		},
	]).get('Reservations', [])
	instances = sum([[i for i in r['Instances']] for r in reservations], [])
	print("Found %d instances that need backing up" % len(instances))
	to_tag = collections.defaultdict(list)
	for instance in instances:
		try:
			retention_days = [
				int(t.get('Value')) for t in instance['Tags']
				if t['Key'] == 'Retention'
			][0]
			pprint.pprint(retention_days)
		except IndexError:
			retention_days = 7
			pprint.pprint(retention_days)
			# Create_image(instance_id, name, description=None, no_reboot=False, block_device_mapping=None, dry_run=False)
			# DryRun, InstanceId, Name, Description, NoReboot, BlockDeviceMappings
			for tag in instance['Tags']:
				if tag['Key'] == 'Name':
					instance_name = tag['Value']
			pprint.pprint(instance_name)

			create_time = datetime.datetime.now()
			create_fmt = create_time.strftime('%Y-%m-%d-%H%M')

			AMIid = ec.create_image(
				InstanceId=instance['InstanceId'],
				Name=instance_name + " - " + instance['InstanceId'] + " from " + create_fmt,
				Description="Lambda created AMI of instance " + instance['InstanceId'] + " from " + create_fmt,
				NoReboot=True,
				DryRun=False)

			pprint.pprint(instance)
			# # Can be used if NoReboot is set to False, and number of instances is small
			# # so that waiting will not go over Lambda timeout of 15 min
			# Wait for image to be available
			# waiter = ec.get_waiter('image_available')
			# waiter.wait(Filters=[{
			# 	'Name': 'image-id',
			# 	'Values': [AMIid['ImageId']]
			# }])
			to_tag[retention_days].append(AMIid['ImageId'])
			print("Retaining AMI %s of instance %s for %d days" % (
				AMIid['ImageId'],
				instance['InstanceId'],
				retention_days,
			))
			pprint.pprint(to_tag)

			pprint.pprint(to_tag.keys())
		for retention_days in to_tag.keys():
			delete_date = datetime.date.today() + datetime.timedelta(
				days=retention_days)
		delete_fmt = delete_date.strftime('%Y-%m-%d')
		print("Will delete %d AMIs on %s" % (len(to_tag[retention_days]), delete_fmt))

		# break

		ec.create_tags(Resources=to_tag[retention_days], Tags=[{'Key': 'DeleteOn', 'Value': delete_fmt}])

		pprint.pprint(to_tag[retention_days])
