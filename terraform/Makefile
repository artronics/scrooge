-include .env

tf = AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) terraform

.SILENT:

init:
	$(tf) init -backend-config="bucket=scrooge-ptl-terraform-state"

plan:
	$(tf) plan

apply:
	$(tf) workspace select default
	$(tf) apply -auto-approve -var="tag=develop"

apply-test:
	$(tf) workspace select test
	$(tf) apply -auto-approve -var="tag=develop"

lock-provider:
	$(tf) providers lock -platform=darwin_arm64 -platform=darwin_amd64 -platform=linux_amd64 -platform=windows_amd64

.PHONY: init plan lock-provider
