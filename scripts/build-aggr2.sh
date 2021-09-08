#!/bin/bash

GITDIR=$(git rev-parse --show-toplevel)
REGION="us-east-2"
AGGR_AWS_ACCOUNT_ID=""
MEMBER_AWS_ACCOUNT_ID=""

set -euo pipefail

# This deployment can only be started when all recorder stack instnces have been deployed
echo "### Deploy config rule stack set and stack instances ###"
cd $GITDIR/aggr-account/config-rules
aws cloudformation create-stack-set --stack-set-name config-rule-ec2 --template-body file://config-rule-ec2.yml --capabilities CAPABILITY_NAMED_IAM --permission-model SELF_MANAGED 


aws cloudformation create-stack-instances \
--stack-set-name config-rule-ec2 \
--deployment-targets Accounts="$AGGR_AWS_ACCOUNT_ID,$MEMBER_AWS_ACCOUNT_ID" \
--regions "us-east-1" "us-east-2" \
--operation-preferences FailureToleranceCount=5 \
--region $REGION
