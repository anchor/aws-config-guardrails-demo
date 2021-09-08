#!/usr/bin/env bash

GITDIR=$(git rev-parse --show-toplevel)
REGION="us-east-2"

set -euo pipefail

# echo "### Delete bad architecture"
aws cloudformation delete-stack --stack-name bad-architecture-compute
aws cloudformation delete-stack --stack-name bad-architecture-s3 
aws cloudformation delete-stack --stack-name bad-architecture-infra 

cd $GITDIR/scripts
