-include .env

.SILENT:

aws_cred = AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) IAM_ROLE_ARN=$(IAM_ROLE_ARN)
envs = $(aws_cred) S3_BUCKET=$(S3_BUCKET)

run:
	$(envs) go run main.go

repo = artronics
tag = local

docker-build:
	docker build -t $(repo)/scrooge:$(tag) .


docker-run: docker-build
	docker run --rm -it -v $(shell pwd)/volume-cache:/cache \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	$(opt)	$(repo)/scrooge:$(tag)

