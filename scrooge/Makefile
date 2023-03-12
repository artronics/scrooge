-include .env

BUILDDIR = build

aws_cred = AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) IAM_ROLE_ARN=$(IAM_ROLE_ARN)
envs = $(aws_cred) S3_BUCKET=$(S3_BUCKET)

.SILENT:

native-build: | $(BUILDDIR)
	go build -o $(BUILDDIR)/native-scrooge github.com/artronics/scrooge

aws-build: | $(BUILDDIR)
	GO111MODULE=on GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o $(BUILDDIR)/aws-scrooge github.com/artronics/scrooge
	zip -j $(BUILDDIR)/aws-scrooge.zip $(BUILDDIR)/aws-scrooge

run:
	$(envs) go run  main.go

repo = artronics
tag = local

docker-build:
	docker build -t $(repo)/scrooge:$(tag) .

mode = destroy
s3_bucket = scrooge-resources
docker-run: docker-build
	docker run --rm -it --memory=512m --cpus=1 \
	-v $(shell pwd)/../volume-projects:/mnt/projects \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	-e MODE=$(mode) -e S3_BUCKET=$(s3_bucket) \
	$(opt)	$(repo)/scrooge:$(tag)

$(BUILDDIR):
	mkdir $(BUILDDIR)
