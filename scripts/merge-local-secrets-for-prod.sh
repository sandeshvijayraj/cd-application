#!/usr/bin/env bash
# Build ~/aimarketing.secrets.env from local backend/.env for production.
# Keeps production DATABASE_URL + CloudFront URLs out of this file (ConfigMap handles those).
# Never copies MinIO (minioadmin) keys — pass AWS keys via S3_ACCESS_KEY_PROD / S3_SECRET_KEY_PROD.
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

POSTGRES_PW="${POSTGRES_PASSWORD:-}"
if [[ -z "$POSTGRES_PW" ]]; then
  echo "WARN: POSTGRES_PASSWORD not in $LOCAL_ENV — omitting DATABASE_URL from output." >&2
  echo "      Keep existing DB secret on cluster or set POSTGRES_PASSWORD before apply." >&2
  DB_BLOCK=""
else
  DB_BLOCK="POSTGRES_PASSWORD=${POSTGRES_PW}
DATABASE_URL=postgresql+psycopg://aimarketing:${POSTGRES_PW}@postgres:5432/aimarketing"
fi

# Prefer explicit prod AWS keys. Never ship local MinIO credentials.
if [[ -n "${S3_ACCESS_KEY_PROD:-}" && -n "${S3_SECRET_KEY_PROD:-}" ]]; then
  S3_AK="$S3_ACCESS_KEY_PROD"
  S3_SK="$S3_SECRET_KEY_PROD"
elif [[ -n "${S3_ACCESS_KEY:-}" && "${S3_ACCESS_KEY}" != "minioadmin" ]]; then
  S3_AK="$S3_ACCESS_KEY"
  S3_SK="${S3_SECRET_KEY:-}"
else
  S3_AK=""
  S3_SK=""
  echo "WARN: S3 keys omitted (local MinIO or empty). Set S3_ACCESS_KEY_PROD/S3_SECRET_KEY_PROD," >&2
  echo "      or leave cluster secret S3_* keys as-is when applying." >&2
fi

{
  echo "# Generated $(date -u +%Y-%m-%dT%H:%MZ) — do not commit"
  echo "${DB_BLOCK}"
  echo
  echo "AUTH_JWT_SECRET=${AUTH_JWT_SECRET:-}"
  echo "NEXTAUTH_SECRET=${NEXTAUTH_SECRET:-}"
  echo "SCHEDULER_SECRET=${SCHEDULER_SECRET:-}"
  echo "TOKEN_ENCRYPTION_KEY=${TOKEN_ENCRYPTION_KEY:-}"
  echo
  echo "OPENROUTER_API_KEY=${OPENROUTER_API_KEY:-}"
  echo "GOOGLE_API_KEY=${GOOGLE_API_KEY:-}"
  echo "GROQ_API_KEY=${GROQ_API_KEY:-}"
  echo
  if [[ -n "$S3_AK" && -n "$S3_SK" ]]; then
    echo "S3_ACCESS_KEY=${S3_AK}"
    echo "S3_SECRET_KEY=${S3_SK}"
  fi
  echo
  echo "GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET:-}"
  echo "META_APP_SECRET=${META_APP_SECRET:-}"
  echo "META_IG_APP_ID=${META_IG_APP_ID:-}"
  echo "META_IG_APP_SECRET=${META_IG_APP_SECRET:-}"
  echo "META_WEBHOOK_VERIFY_TOKEN=${META_WEBHOOK_VERIFY_TOKEN:-}"
} >"$OUT"

chmod 600 "$OUT"
echo "Wrote $OUT"
echo "Apply: ./scripts/apply-secrets.sh $OUT"
