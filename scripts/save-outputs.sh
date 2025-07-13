#!/usr/bin/env bash
# Collects outputs for each stack passed as argument(s)
# Writes infra/outputs.txt and (if S3_BUCKET_NAME is set) uploads to S3

set -euo pipefail
mkdir -p infra
OUTFILE="infra/outputs.txt"
> "$OUTFILE"

for STACK in "$@"; do
  echo "### $STACK" >> "$OUTFILE"

  # Query each output's key + value
  aws cloudformation describe-stacks \
    --stack-name "$STACK" \
    --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" \
    --output text |
    awk '{printf "  %s = %s\n",$1,$2}' >> "$OUTFILE" || true

  echo "" >> "$OUTFILE"
done

echo "Outputs written to $OUTFILE"

# Optional S3 upload
if [[ -n "${S3_BUCKET_NAME:-}" ]]; then
  KEY="${1}/outputs.txt"      # use first stack for folder prefix
  aws s3 cp "$OUTFILE" "s3://${S3_BUCKET_NAME}/${KEY}"
  echo "Uploaded to s3://${S3_BUCKET_NAME}/${KEY}"
fi
