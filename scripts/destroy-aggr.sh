#!/usr/bin/env bash

GITDIR=$(git rev-parse --show-toplevel)
REGION="us-east-2"
AGGR_AWS_ACCOUNT_ID=""
MEMBER_AWS_ACCOUNT_ID=""

set -euo pipefail

convert_parameters_file_to_list() {
    echo $(jq -r '.[] | [.ParameterKey, .ParameterValue] | join("=")' $1)
}

delete_stack_instances () {
    STACK_SET_NAME=$1
    echo -e "... Delete $STACK_SET_NAME"
    aws cloudformation delete-stack-instances \
    --stack-set-name $STACK_SET_NAME \
    --deployment-targets Accounts="$AGGR_AWS_ACCOUNT_ID,$MEMBER_AWS_ACCOUNT_ID" \
    --regions us-east-2 us-east-1 \
    --operation-preferences FailureToleranceCount=1,MaxConcurrentCount=10 \
    --no-retain-stacks 
}

echo "### empty the S3 buckets ###"
aws s3 rm s3://config-aggr-$AGGR_AWS_ACCOUNT_ID-us-east-2 --recursive
aws s3 rm s3://config-aggr-$AGGR_AWS_ACCOUNT_ID-us-east-1 --recursive

aws s3 rb s3://config-aggr-$AGGR_AWS_ACCOUNT_ID-us-east-2 --force 
aws s3 rb s3://config-aggr-$AGGR_AWS_ACCOUNT_ID-us-east-1 --force

echo "### Delete EC2 config rule stack instance ###"
cd $GITDIR/aggr-account/config-rules
delete_stack_instances config-rule-ec2 

echo "### Delete config-recorder-accounts stack set ###"
# Please note: if the process gets stuck here, you will need to run the delete-s3-buckets scripts in each account before continuing here
cd $GITDIR/aggr-account/shared-resources
delete_stack_instances config-recorder-accounts 

echo "### Delete S3 bucket for config aggregator"
cd $GITDIR/aggr-account/shared-resources
aws cloudformation delete-stack --stack-name s3bucket-config-aggr
echo "### Delete Config aggregator"
aws cloudformation delete-stack --stack-name configuration-aggregator

echo "### You need to delete the stack sets manually after the stack stack instances are deleted ###"

cd $GITDIR/scripts
