package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"log"
	"time"
)

var deleteDate = time.Now().AddDate(0, 0, 7).Format("2006-01-02")

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
			err = makeInstanceSnapshot(context.TODO(), cfg, *instance.InstanceId)
			if err != nil {
				log.Fatalf("unable to make instance snapshot, %v", err)
			}
		}
	}
}

// makeInstanceSnapshot creates an image of an instance and add tags of a date
func makeInstanceSnapshot(ctx context.Context, cfg aws.Config, instanceID string) error {
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
						Value: aws.String(deleteDate),
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
