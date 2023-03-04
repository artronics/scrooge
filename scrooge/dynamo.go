package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/expression"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"log"
)

type Resource struct {
	Id        string `json:"id"`
	Project   string `json:"project"`
	CheckedAt string `json:"checked_at"`
}

type ResourcesTable struct {
	DynamoDbClient *dynamodb.Client
	TableName      string
}

func NewResourceTable(cfg *aws.Config, tableName string) ResourcesTable {
	svc := dynamodb.NewFromConfig(*cfg)
	return ResourcesTable{
		svc,
		tableName,
	}
}

func (t ResourcesTable) GetActive() {
	var err error
	var response *dynamodb.QueryOutput
	var records []Resource
	keyEx := expression.Key("id").Equal(expression.Value("test1"))
	expr, err := expression.NewBuilder().WithKeyCondition(keyEx).Build()
	if err != nil {
		log.Printf("Couldn't build expression for query. Here's why: %v\n", err)
	} else {
		response, err = t.DynamoDbClient.Query(context.TODO(), &dynamodb.QueryInput{
			TableName:                 aws.String(t.TableName),
			ExpressionAttributeNames:  expr.Names(),
			ExpressionAttributeValues: expr.Values(),
			KeyConditionExpression:    expr.KeyCondition(),
		})
		if err != nil {
			log.Printf("Couldn't query for records released %s", err)
		} else {
			err = attributevalue.UnmarshalListOfMaps(response.Items, &records)
			if err != nil {
				log.Printf("Couldn't unmarshal query response. Here's why: %v\n", err)
			}
			fmt.Printf("%s\n", records)
			fmt.Printf("%s\n", records[0].CheckedAt)
		}
	}
}
