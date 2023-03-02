package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
)

type MyEvent struct {
	Name string `json:"name"`
}

func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	return fmt.Sprintf("yoo %s!", name.Name), nil
}

func main() {
	fmt.Println("running!")
	lambda.Start(HandleRequest)
}
