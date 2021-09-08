#!/usr/bin/env bash

GITDIR=$(git rev-parse --show-toplevel)
REGION="us-east-2"

set -euo pipefail

convert_parameters_file_to_list() {
    echo $(jq -r '.[] | [.ParameterKey, .ParameterValue] | join("=")' $1)
}

deploy_cf () {
    STACK_NAME=$1
    TEMPLATE_FILE=$2

    echo -e "...Provisioning $STACK_NAME"
    if [[ $# == 3 ]]; 
      then
      PARAMETER_LIST="$(convert_parameters_file_to_list $3)"

      aws cloudformation deploy \
      --stack-name $STACK_NAME \
      --template-file $TEMPLATE_FILE \
      --parameter-overrides $PARAMETER_LIST \
      --capabilities CAPABILITY_NAMED_IAM \
      --no-fail-on-empty-changeset \
      --region $REGION

      else
      aws cloudformation deploy \
      --stack-name $STACK_NAME \
      --template-file $TEMPLATE_FILE \
      --capabilities CAPABILITY_NAMED_IAM \
      --no-fail-on-empty-changeset \
      --region $REGION
    fi

}

echo "### Deploy IAM role for aggregator access ###"
cd $GITDIR/application-accounts/shared-resources
deploy_cf iam-stackset-exec-role iam-stackset-exec-role.yml iam-stackset-exec-role.json

echo "### Deploy a non-compliant architecture so that we get some findings"
cd $GITDIR/application-accounts/bad-architecture
deploy_cf bad-architecture-infra bad-architecture-infra.yml 
deploy_cf bad-architecture-s3 bad-architecture-s3.yml 

cd $GITDIR/scripts
