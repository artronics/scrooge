package main

import (
	"context"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"io"
	"time"
)

type RecordTime struct {
	time.Time
}

func (t *RecordTime) UnmarshalJSON(b []byte) (err error) {
	date, err := time.Parse(`"2023-03-04T02:22:05+00:00"`, string(b))
	if err != nil {
		return err
	}
	t.Time = date
	return
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
	cfg, err := awsConf()
	if err != nil {
		panic(err.Error())
	}
	s3Res := S3Bucket{S3Client: s3.NewFromConfig(*cfg)}
	res, err := s3Res.DownloadFile("scrooge-test-resources", "db.json")
	if err != nil {
		panic(err.Error())
	}
	checkResources(res)

	fmt.Printf("%s\n", res)
	lambda.Start(HandleRequest)
}

func checkResources(db []ResourceRecord) error {
	for record := range db {
		fmt.Printf("%s", record)
	}

	return nil
}

func awsConf() (*aws.Config, error) {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("eu-west-2"))
	if err != nil {
		return nil, err
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
	if err := json.Unmarshal(body, &resDb); err != nil {
		return resDb, err
	}

	return resDb, err
}
