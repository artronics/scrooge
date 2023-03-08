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

type Record struct {
	Project   string     `json:"project"`
	Workspace string     `json:"workspace"`
	Resources []Resource `json:"resources"`
}

type Resource struct {
	Id        string     `json:"id"`
	Strategy  string     `json:"strategy"`
	CheckedAt RecordTime `json:"checked_at"`
}

func (r Record) NeedsChecking() bool {
	return false
}

func HandleRequest(ctx context.Context, record Record) (string, error) {
	iamRole := os.Getenv("IAM_ROLE_ARN")
	s3Bucket := os.Getenv("S3_BUCKET")
	var mode = "add"
	if os.Getenv("MODE") == "destroy" {
		mode = "destroy"
	}
	fmt.Printf("s3 bucket: %s\n", s3Bucket)
	fmt.Printf("iam role: %s\n", iamRole)
	fmt.Printf("mode: %s\n", mode)

	cfg, err := awsConf(iamRole)
	if err != nil {
		panic(err.Error())
	}

	s3Res := S3Bucket{S3Client: s3.NewFromConfig(*cfg)}
	objKey := "db.json"
	db, err := s3Res.DownloadFile(s3Bucket, objKey)
	if err != nil {
		panic(err.Error())
	}
	if mode == "destroy" {
		if err = checkResources(db); err != nil {
			panic(err.Error())
		}
		return fmt.Sprintf("destroy %s!", "resources"), nil
	} else {
		dbModified, err := updateOrAddRecord(db, record)
		if err != nil {
			panic(err.Error())
		}
		if err = s3Res.WriteFile(s3Bucket, objKey, dbModified); err != nil {
			panic(err.Error())
		}
		return fmt.Sprintf("Added or updated %s!", record), nil
	}
}

func checkResources(db []Record) error {
	for _, record := range db {
		fmt.Printf("%s", record)
	}
	return nil
}

func updateOrAddRecord(db []Record, record Record) ([]Record, error) {
	for i, r := range db {
		if r.Project == record.Project && r.Workspace == record.Workspace {
			fmt.Printf("record updated:\n %s\n", record)
			db[i] = record
			return db, nil
		}
	}

	fmt.Printf("add new record:\n %s\n", record)
	db = append(db, record)
	return db, nil
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

func (basics S3Bucket) DownloadFile(bucketName string, objectKey string) ([]Record, error) {
	resDb := make([]Record, 0)
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

func (basics S3Bucket) WriteFile(bucketName string, objectKey string, db []Record) error {
	content, err := json.Marshal(db)
	if err != nil {
		return err
	}

	contentType := "application/json"
	_, err = basics.S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket:      aws.String(bucketName),
		Key:         aws.String(objectKey),
		Body:        bytes.NewReader(content),
		ContentType: &contentType,
	})

	return err
}

func main() {
	lambda.Start(HandleRequest)
}
