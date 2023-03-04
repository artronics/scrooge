package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
)

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
	table := NewResourceTable(cfg, "scrooge_resources")
	table.GetActive()
	lambda.Start(HandleRequest)
}

func awsConf() (*aws.Config, error) {
	cfg, err := config.LoadDefaultConfig(context.TODO(), config.WithRegion("eu-west-2"))
	if err != nil {
		return nil, err
	}

	return &cfg, nil
}
