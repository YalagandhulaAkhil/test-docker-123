#!/usr/bin/env bash
# read-s3-outputs.sh <stack> <key>
# Prints the value for <key> found in s3://${S3_BUCKET_NAME}/<stack>/outputs.txt
set -euo pipefail
STACK=$1
KEY=$2
aws s3 cp "s3://${S3_BUCKET_NAME}/${STACK}/outputs.txt" - 2>/dev/null |
grep -E "^[[:space:]]*$KEY[[:space:]]*=" |
awk -F'=' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}'
