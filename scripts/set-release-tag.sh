#!/usr/bin/env bash
# Pin app image tags in this GitOps repo after ECR tag builds succeed.
#
# Usage (from cd-application root):
#   ./scripts/set-release-tag.sh v0.1.1
#   git push origin main
#
# Argo CD auto-syncs apps/aimarketing and rolls pods to those tags.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${1:-}"
if [[ -z "$TAG" || "$TAG" != v* ]]; then
  echo "Usage: $0 vX.Y.Z" >&2
  exit 1
fi

ACCOUNT="${AWS_ACCOUNT_ID:-788612735038}"
REGION="${AWS_REGION:-ap-south-1}"
REG="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"

for svc in backend frontend scheduler; do
  f="$ROOT/apps/aimarketing/${svc}/deployment.yaml"
  sed -i.bak -E "s|(image: ${REG}/aimarketing-${svc}):[^[:space:]]+|\\1:${TAG}|g" "$f"
  rm -f "${f}.bak"
  grep -E "image:.*aimarketing-${svc}:" "$f"
done

echo
echo "Pinned images to ${TAG}. Next:"
echo "  git add apps/aimarketing/*/deployment.yaml"
echo "  git commit -m \"Deploy ${TAG}\""
echo "  git push origin main"
echo "Argo CD will sync automatically."
