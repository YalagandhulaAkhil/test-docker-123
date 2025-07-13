#!/usr/bin/env bash
#
# save-outputs.sh  –  Collect CloudFormation stack outputs into outputs.txt
# Usage:
#   AWS_DEFAULT_REGION=us-east-1 ./save-outputs.sh my-vpc-stack my-iam-stack ecr-stack ecs-cluster-stack
#   (or just run without args to dump ALL stacks in the account)

OUTFILE="outputs.txt"
: > "$OUTFILE"  # truncate

# If stack names are supplied as arguments, use them; otherwise query all stacks
if [ "$#" -gt 0 ]; then
  stacks=("$@")
else
  mapfile -t stacks < <(aws cloudformation list-stacks \
      --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
      --query "StackSummaries[].StackName" --output text)
fi

for stack in "${stacks[@]}"; do
  echo "### $stack" >> "$OUTFILE"

  aws cloudformation describe-stacks --stack-name "$stack" \
    --query "Stacks[0].Outputs[]" --output text |
    awk '{printf "  %s = %s\n",$1,$3}' >> "$OUTFILE"

  echo >> "$OUTFILE"
done

echo "Outputs written to $OUTFILE"
