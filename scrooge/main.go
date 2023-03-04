package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials/stscreds"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/sts"
	"io"
	"os"
	"time"
)

type RecordTime struct {
	time.Time
}

func (t *RecordTime) UnmarshalJSON(b []byte) (err error) {
	if string(b) == "null" || string(b) == `""` {
		return nil
	}
	dateTime, err := time.Parse(`"`+time.RFC3339+`"`, string(b))
	*t = RecordTime{dateTime}
	return err
}

type ResourceRecord struct {
	Project   string     `json:"project"`
	Workspace string     `json:"workspace"`
	Resource  string     `json:"resource"`
	Name      string     `json:"name"`
	CheckedAt RecordTime `json:"checked_at"`
}

func (r ResourceRecord) NeedsChecking() bool {
	return false
}

type MyEvent struct {
	Name string `json:"name"`
}

func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	return fmt.Sprintf("yoo %s!", name.Name), nil
}

func main() {
	fmt.Println("running!")
	iamRole := os.Getenv("IAM_ROLE_ARN")
	s3Bucket := os.Getenv("S3_BUCKET")
	fmt.Printf("s3 bucket: %s\n", s3Bucket)
	fmt.Printf("iam role: %s\n", iamRole)

	cfg, err := awsConf(iamRole)
	if err != nil {
		panic(err.Error())
	}

	s3Res := S3Bucket{S3Client: s3.NewFromConfig(*cfg)}
	res, err := s3Res.DownloadFile(s3Bucket, "db.json")
	if err != nil {
		panic(err.Error())
	}
	if err = checkResources(res); err != nil {
		panic(err.Error())
	}

	fmt.Printf("%s\n", res)
	lambda.Start(HandleRequest)
}

func checkResources(db []ResourceRecord) error {
	for record := range db {
		fmt.Printf("%s", record)
	}

	return nil
}

func awsConf(iamRole string) (*aws.Config, error) {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("eu-west-2"))
	if err != nil {
		return nil, err
	}

	if os.Getenv("AWS_ACCESS_KEY_ID") == "" {
		stsClient := sts.NewFromConfig(cfg)
		provider := stscreds.NewAssumeRoleProvider(stsClient, iamRole)
		cfg.Credentials = aws.NewCredentialsCache(provider)
	}

	return &cfg, nil
}

type S3Bucket struct {
	S3Client *s3.Client
}

func (basics S3Bucket) DownloadFile(bucketName string, objectKey string) ([]ResourceRecord, error) {
	resDb := make([]ResourceRecord, 0)
	result, err := basics.S3Client.GetObject(context.TODO(), &s3.GetObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(objectKey),
	})
	if err != nil {
		return resDb, err
	}

	body, err := io.ReadAll(result.Body)
	reader := bytes.NewReader(body)
	//body := strings.NewReader(result.Body)
	if err := json.NewDecoder(reader).Decode(&resDb); err != nil {
		return resDb, err
	}

	return resDb, err
}
