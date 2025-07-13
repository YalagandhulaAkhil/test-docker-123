#!/usr/bin/env bash
# Collects all outputs for a stack and uploads to S3
set -euo pipefail

STACK_NAME=$1
S3_BUCKET_NAME=${S3_BUCKET_NAME:-}

if [[ -z "$S3_BUCKET_NAME" ]]; then
  echo "❌  S3_BUCKET_NAME not provided"
  exit 1
fi

mkdir -p infra
OUTFILE="infra/outputs.txt"
> "$OUTFILE"

echo "### $STACK_NAME" >> "$OUTFILE"

aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" \
  --output text |
  awk '{printf "  %s = %s\n",$1,$2}' >> "$OUTFILE"

echo "✅  Outputs written to $OUTFILE"

aws s3 cp "$OUTFILE" "s3://${S3_BUCKET_NAME}/${STACK_NAME}/outputs.txt"
echo "✅  Uploaded to s3://${S3_BUCKET_NAME}/${STACK_NAME}/outputs.txt"
