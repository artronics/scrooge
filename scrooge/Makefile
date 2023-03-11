-include .env

BUILDDIR = build

aws_cred = AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) IAM_ROLE_ARN=$(IAM_ROLE_ARN)
envs = $(aws_cred) S3_BUCKET=$(S3_BUCKET)

.SILENT:

native-build: | $(BUILDDIR)
	go build -o $(BUILDDIR)/native-scrooge github.com/artronics/scrooge

run:
	$(envs) go run  main.go

repo = artronics
tag = local

docker-build:
	docker build -t $(repo)/scrooge:$(tag) .

docker-run: docker-build
	docker run --rm -it \
	-v $(shell pwd)/../volume-projects:/mnt/projects \
	-e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	$(opt)	$(repo)/scrooge:$(tag)

$(BUILDDIR):
	mkdir $(BUILDDIR)
