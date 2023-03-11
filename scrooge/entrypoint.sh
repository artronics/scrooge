#!/bin/sh
set -e

cd /
mkdir -p "/mnt/projects/.terraform.d/plugin-cache"

scrooge
# destroy scrooge-resource-test default "-target=aws_s3_bucket.scrooge-resource-test-test-2"
