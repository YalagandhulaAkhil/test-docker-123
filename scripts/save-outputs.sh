#!/usr/bin/env bash
set -euo pipefail

STACK_NAME=$1
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
  aws s3 cp "$OUTFILE" "s3://${S3_BUCKET_NAME}/${STACK_NAME}/outputs.txt"
fi
