#!/bin/sh
set -e

cd /
mkdir -p "$HOME/.terraform.d/plugin-cache/" > /dev/null 2>&1

scrooge
/bin/sh

#terraform init -backend-config="bucket=scrooge-resource-test-ptl-terraform-state"
