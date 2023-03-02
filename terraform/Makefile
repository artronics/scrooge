-include .env

tf = terraform

init:
	$(tf) init -backend-config="bucket=scrooge-ptl-terraform-state"

plan:
	$(tf) plan

apply:
	$(tf) apply -auto-approve -var="tag=develop"

lock-provider:
	$(tf) providers lock -platform=darwin_arm64 -platform=darwin_amd64 -platform=linux_amd64 -platform=windows_amd64

.PHONY: init plan lock-provider
