#!/usr/bin/env bash
# scripts/save-outputs.sh
# Usage: ./scripts/save-outputs.sh stack1 stack2 …

set -euo pipefail

OUTFILE="scripts/outputs.txt"
mkdir -p scripts
: > "$OUTFILE"

for STACK in "$@"; do
  STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK" \
            --query "Stacks[0].StackStatus" --output text 2>/dev/null || true)

  if [[ -z "$STATUS" ]]; then
    echo "### $STACK (stack not found)" >> "$OUTFILE"
    echo "" >> "$OUTFILE"
    continue
  fi

  echo "### $STACK ($STATUS)" >> "$OUTFILE"

  aws cloudformation describe-stacks --stack-name "$STACK" \
    --query "Stacks[0].Outputs[]" \
    --output text |
    awk '{printf "  %s = %s\n",$1,$3}' >> "$OUTFILE" || true

  echo "" >> "$OUTFILE"
done

echo "Outputs written to $OUTFILE"
