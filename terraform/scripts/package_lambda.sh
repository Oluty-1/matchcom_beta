#!/bin/bash
set -e
function_dir=$1
function_name=$(basename "$function_dir")
bucket="compatibility-bucket-test"
s3_key="functions/$function_name/function.zip"
cd "$function_dir"
zip -r function.zip .
source_code_hash=$(openssl dgst -sha256 -binary function.zip | base64)
aws s3 cp function.zip s3://$bucket/$s3_key --metadata "source_code_hash=$source_code_hash"
rm function.zip
echo "Packaged and uploaded $function_name to s3://$bucket/$s3_key"