// Added comment to test action
package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/aws/aws-sdk-go-v2/service/sns"
	"log"
	"os"
	"strconv"
	"time"
)

func main() {
	lambda.Start(HandleRequest)
}
func HandleRequest() {
	// Using the SDK's default configuration, loading additional config
	// and credentials values from the environment variables, shared
	// credentials, and shared configuration files
	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		log.Fatalf("unable to load SDK config, %v", err)
	}
	ec2client := ec2.NewFromConfig(cfg)
	// define sns topic client
	snsClient := sns.NewFromConfig(cfg)
	// get sns topic arn from environment variable
	topicArn := os.Getenv("SNS_TOPIC_ARN")
	if topicArn == "" {
		log.Fatal("SNS_TOPIC_ARN environment variable must be set")
	}

	params := &ec2.DescribeInstancesInput{
		Filters: []types.Filter{
			{
				Name:   aws.String("tag:Backup"),
				Values: []string{"true"},
			},
		},
	}

	instances, err := ec2client.DescribeInstances(context.TODO(), params)
	if err != nil {
		log.Fatalf("unable to get instances, %v", err)
	}
	// iterate over reservations and print instance IDs and make instance snapshots
	for _, reservation := range instances.Reservations {
		for _, instance := range reservation.Instances {
			fmt.Println("Instance ID: ", *instance.InstanceId)
			// get backup retention days from tag values
			retentionDays := getBackupRetentionDays(instance)
			deleteDate := time.Now().AddDate(0, 0, retentionDays).Format("2006-01-02")
			err = makeInstanceSnapshot(context.TODO(), cfg, *instance.InstanceId, deleteDate)
			if err != nil {
				log.Fatalf("unable to make instance snapshot, %v", err)
			}
			// publish message to sns topic
			_, err := snsClient.Publish(context.TODO(), &sns.PublishInput{
				Subject:  aws.String("EC2 Snapshot notification"),
				Message:  aws.String("Instance ID: " + *instance.InstanceId + " Snapshot ID: " + *instance.InstanceId + "-" + time.Now().Format("2006-01-02")),
				TopicArn: aws.String(topicArn),
			})
			if err != nil {
				log.Fatalf("unable to publish message to sns topic, %v", err)
			}
		}
	}
}

// makeInstanceSnapshot creates an image of an instance and add tags of a date
func makeInstanceSnapshot(ctx context.Context, cfg aws.Config, instanceID string, delete string) error {
	svc := ec2.NewFromConfig(cfg)
	input := &ec2.CreateImageInput{
		Name:        aws.String(instanceID + "-" + time.Now().Format("2006-01-02")),
		Description: aws.String("Lambda Snapshot of " + instanceID),
		InstanceId:  aws.String(instanceID),
		TagSpecifications: []types.TagSpecification{
			{
				ResourceType: types.ResourceTypeImage,
				Tags: []types.Tag{
					{
						Key:   aws.String("DeleteOn"),
						Value: aws.String(delete),
					},
				},
			},
		},
	}
	result, err := svc.CreateImage(ctx, input)
	if err != nil {
		return err
	}
	fmt.Println("Snapshot ID: ", *result.ImageId)
	return nil
}

// getBackupRetentionDays will get the backup retention days from the tag value
// if the tag is not set, it will return 7 days
func getBackupRetentionDays(instance types.Instance) int {
	for _, tag := range instance.Tags {
		if *tag.Key == "BackupRetentionDays" {
			intValue, err := strconv.Atoi(*tag.Value)
			if err != nil {
				log.Fatalf("unable to convert tag value to int, %v", err)
				return 7
			}
			return intValue
		}
	}
	return 0
}
