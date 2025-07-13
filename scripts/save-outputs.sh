#!/usr/bin/env bash
# Collect outputs of given stack and write infra/outputs.txt, then upload to S3.

set -euo pipefail

STACK_NAME=$1
mkdir -p infra
OUTFILE="infra/outputs.txt"
> "$OUTFILE"

echo "### $STACK_NAME" >> "$OUTFILE"

aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" \
  --output text |
  awk '{printf "  %s = %s\n",$1,$2}' >> "$OUTFILE" || true

echo "Outputs written to $OUTFILE"

if [[ -n "${S3_BUCKET_NAME:-}" ]]; then
  aws s3 cp "$OUTFILE" "s3://${S3_BUCKET_NAME}/${STACK_NAME}/outputs.txt"
  echo "Uploaded to s3://${S3_BUCKET_NAME}/${STACK_NAME}/outputs.txt"
fi
