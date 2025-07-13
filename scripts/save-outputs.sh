#!/usr/bin/env bash
# scripts/save-outputs.sh
# Usage: ./scripts/save-outputs.sh <stack-name>
# Writes infra/outputs.txt and (if S3_BUCKET_NAME is set) uploads it to S3.

set -euo pipefail

STACK_NAME=${1:-}
if [[ -z "$STACK_NAME" ]]; then
  echo "❌  Usage: $0 <stack-name>"
  exit 1
fi

mkdir -p infra
OUTFILE="infra/outputs.txt"
> "$OUTFILE"

echo "### $STACK_NAME" >> "$OUTFILE"

aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[]" \
  --output text |
  awk '{printf "  %s = %s\n",$1,$3}' >> "$OUTFILE" || true

echo "Outputs written to $OUTFILE"

if [[ -n "${S3_BUCKET_NAME:-}" ]]; then
  KEY="${STACK_NAME}/outputs.txt"
  echo "Uploading to s3://${S3_BUCKET_NAME}/${KEY}"
  aws s3 cp "$OUTFILE" "s3://${S3_BUCKET_NAME}/${KEY}"
fi
