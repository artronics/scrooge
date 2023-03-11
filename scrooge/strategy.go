package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"regexp"
	"time"
)

type S3Inactivity struct {
	s3Bucket S3Bucket
	bucket   string
	key      string
}

func parseObjFullPath(objPath string) (string, string, error) {
	re := regexp.MustCompile(`^([^\/]+)\/(.+)$`)
	match := re.FindStringSubmatch(objPath)
	if len(match) != 3 {
		return "", "", fmt.Errorf("s3 Object full path is invalid. It should be in format: <bucket>/path/to/object")
	}

	return match[1], match[2], nil
}

func NewS3Inactivity(config aws.Config, objectAddress string) (S3Inactivity, error) {
	bucket, key, err := parseObjFullPath(objectAddress)
	if err != nil {
		return S3Inactivity{}, err
	}
	s3Bucket := S3Bucket{S3Client: s3.NewFromConfig(config)}

	return S3Inactivity{
		s3Bucket: s3Bucket,
		bucket:   bucket,
		key:      key,
	}, nil
}

func (i S3Inactivity) ShouldBeDeleted(expiryMinute int) (bool, error) {
	modifiedAt, err := i.s3Bucket.ModifiedAt(i.bucket, i.key)
	fmt.Printf("ModifiedAt: %s\n", modifiedAt)
	if err != nil {
		return false, err
	}
	now := time.Now()

	return modifiedAt.Before(now.Add(time.Minute * time.Duration(expiryMinute))), nil
}
