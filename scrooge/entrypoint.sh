#!/bin/sh
set -e

cd /
mkdir -p "/mnt/projects/.terraform.d/plugin-cache"

#echo test storage
#touch /mnt/projects/test
#echo "hello" > /mnt/projects/test
#cat /mnt/projects/test

scrooge
#/bin/sh
# destroy scrooge-resource-test default -target=aws_s3_bucket.test-1-resource
