-include .env

tf = AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) terraform

.SILENT:

init:
	$(tf) init -backend-config="bucket=scrooge-resource-test-ptl-terraform-state"

plan:
	$(tf) plan

apply:
	$(tf) apply -auto-approve

lock-provider:
	$(tf) providers lock -platform=darwin_arm64 -platform=darwin_amd64 -platform=linux_amd64 -platform=windows_amd64

.PHONY: init plan apply lock-provider
