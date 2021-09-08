GITDIR=$(git rev-parse --show-toplevel)
REGION="us-east-2"

echo "### Deploy S3 Config Rule Pack ###"
cd $GITDIR/conformance-packs
aws configservice put-conformance-pack --conformance-pack-name s3-conformance --template-body file://config-s3-conformance.yml --region $REGION
