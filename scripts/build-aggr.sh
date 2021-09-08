#!/usr/bin/env bash

GITDIR=$(git rev-parse --show-toplevel)
REGION="us-east-2"
AGGR_AWS_ACCOUNT_ID=""
MEMBER_AWS_ACCOUNT_ID=""

set -euo pipefail

convert_parameters_file_to_list() {
    echo $(jq -r '.[] | [.ParameterKey, .ParameterValue] | join("=")' $1)
}

deploy_cf () {
    STACK_NAME=$1
    TEMPLATE_FILE=$2

    echo -e "... Provisioning $STACK_NAME"
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


update_stackset () {
    STACK_NAME=$1
    TEMPLATE_FILE=$2

    echo -e "... Provisioning $STACK_NAME"

    STACK_EXISTS=$(aws cloudformation describe-stack-set --stack-set-name $STACK_NAME)
    if [[ $? == 0 ]]
    then
      STACK_ACTION="update-stack-set"
      # Don't update for the moment. If we do it conflicts with Stack Instances
      # For now, we'll just focus on initial deployment, and not re-running updates
      echo -e "... Stack $STACK_NAME already exists."
    else
      STACK_ACTION="create-stack-set"
      if [[ $# == 3 ]]
      then
        PARAMETER_FILE="$3"

        aws cloudformation $STACK_ACTION \
        --stack-set-name $STACK_NAME \
        --template-body file://$TEMPLATE_FILE \
        --parameters file://$PARAMETER_FILE \
        --capabilities CAPABILITY_NAMED_IAM \
        --permission-model SELF_MANAGED \
        --region $REGION

      else
        aws cloudformation $STACK_ACTION \
        --stack-set-name $STACK_NAME \
        --template-body file://$TEMPLATE_FILE \
        --capabilities CAPABILITY_NAMED_IAM \
        --permission-model SELF_MANAGED \
        --region $REGION
      fi
    fi
}

echo "### Deploy shared resources ###"
cd $GITDIR/aggr-account/shared-resources
deploy_cf iam-stackset-admin-role iam-stackset-admin-role.yml
deploy_cf iam-stackset-exec-role iam-stackset-exec-role.yml iam-stackset-exec-role.json

echo "### Deploy aggregator ###"
cd $GITDIR/aggr-account
deploy_cf configuration-aggregator configuration-aggregator.yml configuration-aggregator.json

cd $GITDIR/aggr-account/shared-resources
echo "### Deploy aggregator stack set and stack instances ###"
aws cloudformation create-stack-set --stack-set-name config-recorder-accounts --template-body file://config-recorder-accounts.yml --parameters file://config-recorder-accounts.json --capabilities CAPABILITY_NAMED_IAM --permission-model SELF_MANAGED

aws cloudformation create-stack-instances \
--stack-set-name config-recorder-accounts \
--deployment-targets Accounts="$AGGR_AWS_ACCOUNT_ID,$MEMBER_AWS_ACCOUNT_ID" \
--regions "us-east-1" "us-east-2" \
--operation-preferences FailureToleranceCount=5 \
--region $REGION
