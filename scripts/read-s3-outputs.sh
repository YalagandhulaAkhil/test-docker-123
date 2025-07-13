#!/usr/bin/env bash
# read-s3-outputs.sh <stack> <key>
# Prints the VALUE for <key> from s3://${S3_BUCKET_NAME}/<stack>/outputs.txt
# Exits 0 even if key is not found (empty output), so caller can check.
set -euo pipefail

STACK=$1
KEY=$2
OBJ="s3://${S3_BUCKET_NAME}/${STACK}/outputs.txt"

# Quietly copy; if file missing, exit 0 (empty output)
if ! aws s3 cp "$OBJ" - 2>/dev/null | grep -q .; then
  echo "(no outputs for $STACK)" >&2
  exit 0
fi

aws s3 cp "$OBJ" - |
grep -E "^[[:space:]]*$KEY[[:space:]]*=" |
awk -F'=' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}'
