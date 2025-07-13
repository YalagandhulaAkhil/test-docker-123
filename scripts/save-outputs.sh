#!/usr/bin/env bash
# save-outputs.sh <stack-name>
#  - writes infra/outputs.txt
#  - uploads it to s3://$S3_BUCKET_NAME/<stack-name>/outputs.txt

set -euo pipefail

STACK_NAME=$1
: "${S3_BUCKET_NAME:?❌  S3_BUCKET_NAME not set}"

mkdir -p infra
OUTFILE="infra/outputs.txt"
> "$OUTFILE"

echo "### $STACK_NAME" >> "$OUTFILE"

aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[*].[OutputKey,OutputValue]" \
  --output text |
  awk '{printf "  %s = %s\n",$1,$2}' >> "$OUTFILE"

echo "🔹 Local outputs.txt"
cat "$OUTFILE"

DEST="s3://${S3_BUCKET_NAME}/${STACK_NAME}/outputs.txt"
aws s3 cp "$OUTFILE" "$DEST"
echo "✅  Uploaded $DEST"
