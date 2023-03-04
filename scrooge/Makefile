-include .env

run:
	AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) go run main.go

repo = artronics
tag = local

docker-build:
	docker build -t $(repo)/scrooge:$(tag) .

