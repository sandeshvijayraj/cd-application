#!/usr/bin/env bash
# Build ~/aimarketing.secrets.env from local backend/.env for production.
# Keeps production DATABASE_URL + CloudFront URLs out of this file (ConfigMap handles those).
# Usage: ./scripts/merge-local-secrets-for-prod.sh [/path/to/ai_marketing/backend/.env]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL_ENV="${1:-$ROOT/../ai_marketing/backend/.env}"
OUT="${HOME}/aimarketing.secrets.env"

if [[ ! -f "$LOCAL_ENV" ]]; then
  echo "Missing local env: $LOCAL_ENV" >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$LOCAL_ENV"
set +a

POSTGRES_PW="${POSTGRES_PASSWORD:-aimarketing-prod-change-me}"

cat >"$OUT" <<EOF
# Generated $(date -u +%Y-%m-%dT%H:%MZ) — do not commit
POSTGRES_PASSWORD=${POSTGRES_PW}
DATABASE_URL=postgresql+psycopg://aimarketing:${POSTGRES_PW}@postgres:5432/aimarketing

AUTH_JWT_SECRET=${AUTH_JWT_SECRET:-}
NEXTAUTH_SECRET=${NEXTAUTH_SECRET:-}
SCHEDULER_SECRET=${SCHEDULER_SECRET:-}
TOKEN_ENCRYPTION_KEY=${TOKEN_ENCRYPTION_KEY:-}

OPENROUTER_API_KEY=${OPENROUTER_API_KEY:-}
GOOGLE_API_KEY=${GOOGLE_API_KEY:-}
GROQ_API_KEY=${GROQ_API_KEY:-}

S3_ACCESS_KEY=${S3_ACCESS_KEY:-}
S3_SECRET_KEY=${S3_SECRET_KEY:-}

GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}
META_APP_SECRET=${META_APP_SECRET:-}
META_IG_APP_ID=${META_IG_APP_ID:-}
META_IG_APP_SECRET=${META_IG_APP_SECRET:-}
META_WEBHOOK_VERIFY_TOKEN=${META_WEBHOOK_VERIFY_TOKEN:-}
EOF

chmod 600 "$OUT"
echo "Wrote $OUT"
echo "Apply: ./scripts/apply-secrets.sh $OUT"
