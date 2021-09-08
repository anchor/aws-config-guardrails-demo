#!/usr/bin/env bash

MEMBER_AWS_ACCOUNT_ID=""

aws s3 rm s3://config-aggr-$MEMBER_AWS_ACCOUNT_ID-us-east-2 --recursive
aws s3 rm s3://config-aggr-$MEMBER_AWS_ACCOUNT_ID-us-east-1 --recursive
aws s3 rm s3://open-bucket-$MEMBER_AWS_ACCOUNT_ID-us-east-2 --recursive

aws s3 rb s3://config-aggr-$MEMBER_AWS_ACCOUNT_ID-us-east-2 --force
aws s3 rb s3://config-aggr-$MEMBER_AWS_ACCOUNT_ID-us-east-1 --force
aws s3 rb s3://open-bucket-$MEMBER_AWS_ACCOUNT_ID-us-east-2 --force
