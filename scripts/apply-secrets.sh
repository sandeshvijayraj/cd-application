#!/usr/bin/env bash
# Create/update K8s Secret aimarketing-secrets from a local env file (never commit that file).
# Usage: ./scripts/apply-secrets.sh ~/aimarketing.secrets.env
set -euo pipefail
ENV_FILE="${1:-}"
REGION="${AWS_REGION:-ap-south-1}"
STACK="${STACK_NAME:-aimarketing-k3s}"

if [[ -z "$ENV_FILE" || ! -f "$ENV_FILE" ]]; then
  echo "Usage: $0 /path/to/aimarketing.secrets.env"
  echo "Template: apps/aimarketing/secrets/keys.env.example"
  exit 1
fi

INSTANCE_ID=$(aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='InstanceId'].OutputValue" --output text)

REMOTE=$(mktemp)
{
  echo '#!/bin/bash'
  echo 'set -euo pipefail'
  echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml'
  echo 'kubectl create namespace aimarketing --dry-run=client -o yaml | kubectl apply -f -'
  echo "cat > /tmp/aim.secrets.env <<'ENVEOF'"
  cat "$ENV_FILE"
  echo 'ENVEOF'
  echo 'kubectl -n aimarketing create secret generic aimarketing-secrets --from-env-file=/tmp/aim.secrets.env --dry-run=client -o yaml | kubectl apply -f -'
  echo 'rm -f /tmp/aim.secrets.env'
  echo 'kubectl -n aimarketing get secret aimarketing-secrets'
  echo 'echo SECRETS_APPLIED'
} >"$REMOTE"

B64=$(base64 <"$REMOTE" | tr -d '\n')
CMD_ID=$(aws ssm send-command --region "$REGION" --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters "{\"commands\":[\"echo $B64 | base64 -d > /tmp/apply-secrets.sh\",\"bash /tmp/apply-secrets.sh\"]}" \
  --query 'Command.CommandId' --output text)

echo "SSM $CMD_ID …"
for _ in $(seq 1 30); do
  ST=$(aws ssm get-command-invocation --region "$REGION" --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
    --query 'Status' --output text 2>/dev/null || echo Pending)
  case "$ST" in Success|Failed|Cancelled|TimedOut) break ;; esac
  sleep 3
done
aws ssm get-command-invocation --region "$REGION" --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,Out:StandardOutputContent,Err:StandardErrorContent}' --output json
rm -f "$REMOTE"
