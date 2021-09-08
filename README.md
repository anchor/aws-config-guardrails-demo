# Callouts for workshop

1. Source code repository (https://github.com/anchor/aws-config-guardrails-demo)
2. If you run this demo in an AWS Organization you have to enable all features in the Organization and also CloudFormation delegation
3. But: We are deploying the aggregator to an account for demo purposes. Hence, we need to deploy the service role to the member account (iam-stackset-exec-role.yml)
4. Each account has its own aggregator S3 bucket per region, which is created in a stack set
5. We enable the Config Recording on an account level instead of an OU level (which would be more manageable for larger deployments)
6. We enable the recording an a second account and also in the aggregator account for demo purposes
7. The account with the Aggregator, needs the IAM role in the application-accounts/iam-stackset-admin-role.yml template. This wouldn't be needed if you do this in the Management account
8. Setup process: the script/build-aggr creates the required IAM role in the member account and scripts/build-aggr.sh creates all stacks and stacksets in the aggregation account. They must be run with the individual account profile.
9. the aggr-accounts/shared-resources/iam-stackset-admin-role.yml template also needs to be deployed in the aggregator account to deploy to other accounts.
10. the application-accounts/shared-resources/iam-stackset-exec-role.yml template needs to be deployed to the application account (trust to above role)
11. Resource clean-up requires the following steps in the member account: run delete-s3-buckets-member-account.sh and destroy-member.sh
12. Resource clean-up requires the following steps in the aggregator account: run delete-s3-buckets-aggr-account.sh and destroy-aggr.sh
13. Conformance Packs need to be rolled out to each individual account when not within an organisation


# Agenda for the workshop

1. Intro - both
2. Presenter 1:
   1. What are guardrails? 
   2. Config pricing and potential cost for this lab (https://aws.amazon.com/config/pricing/)
   3. Code structure, accounts, regions - overview
   4. Scripts: deploy member account
   5. iam-stackset-exec-role.yml 
   6. bad-architecture templates
   7. Callouts for workshop & what are stack sets?
   8. Overview of AWS Config in the AWS Console
3. Presenter 2:
   1. Setup in aggregator account - script
   2. config-recorder-accounts.yml - AWS AggregatorRecorder, Buckets, DeliveryChannel, Authorization
   3. iam-stackset-admin-role & iam-stackset-exec-role - Admin role and Exec role
   4. configuration-aggregator.yml - AccountAggregationSources
   5. Deploy config-s3-conformance.yml - Conformance packs: example for S3
4. Presenter 1:
   1. config-rule-ec2.yml - Config Rule
   2. Auto-remediations
   3. Cleanup


# Helpful URLs

1. Config pricing (https://aws.amazon.com/config/pricing/)
2. Config overview (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/AWS_Config.html)
3. Aggregator (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-config-configurationaggregator.html)
4. Aggregator Authorization (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-config-aggregationauthorization.html
5. Config Rules (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-config-configrule.html)
6. Conformance Packs (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-config-conformancepack.html)
7. Remediations (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-config-remediationconfiguration.html)


# Setup steps

The setup script assume that use use Linux or Mac. If you use a different OS you can lookup the CloudFormation deployment statements in each template
1. Update the scripts with your AWS account IDs and AWS Regions of choice:
   1. scripts/build-aggr.sh
   2. scripts/build-aggr2.sh
   3. scripts/delete-s3-buckets-member-account.sh
   4. scripts/deploy-conformance-packs.sh (region only)
   5. scripts/destroy-aggr.sh
   6. scripts/destroy-member.sh (region only)
2. Update the JSON files with the Parameters matching your AWS Account IDs and update Regions of choice where required
   1. aggr-account/configuration-aggregator.json
   2. aggr-account/shared-resources/config-recorder-accounts.json
   3. aggr-account/shared-resources/iam-stackset-exec-role.json
   4. application-accounts/shared-resources/iam-stackset-exec-role.json
3. Member account: run scripts/build-member.sh - then wait until all templates are deployed
4. Aggregator account: run scripts/build-aggr.sh - then wait  until all stack set instances are deployed
5. Aggregator account: run scripts/build-aggr2.sh
6. Member account (at the end of the demo): application-accounts/bad-architecture/bad-architecture-compute.yml
   1. aws cloudformation create-stack --stack-name bad-architecture-compute --template-body file://bad-architecture-compute.yml 


# Cleanup steps

1. Member account: clear objects in the S3 buckets: scripts/delete-s3-buckets-member-account.sh
2. Aggregation account scripts/destroy-aggr.sh - then wait until the stack set instances are deleted
3. Aggregation account: aws cloudformation delete-stack-set --stack-set-name config-rule-ec2
4. Aggregation account: aws cloudformation delete-stack-set --stack-set-name config-recorder-accounts
5. Member account: scripts/destroy-member.sh
6. Member account: aws cloudformation delete-stack --stack-name iam-stackset-exec-role 
7. Aggregation account: delete the last two IAM roles in the script and validate the stack sets have been deleted
   a. aws cloudformation delete-stack --stack-name iam-stackset-admin-role
   b. aws cloudformation delete-stack --stack-name iam-stackset-exec-role


# Cleanup Validations

1. Make sure all created buckets are deleted in both accounts
2. Make sure both CloudFormation Stack Sets are deleted in the aggregator account
3. Make sure all CloudFormation Stacks are deleted in both accounts


# LinkedIn:

[Gerald Bachlmayr] (https://www.linkedin.com/in/bachlmayr/)
[Anthony Spruce] (https://www.linkedin.com/in/anthony-spruce-59327a43/)
