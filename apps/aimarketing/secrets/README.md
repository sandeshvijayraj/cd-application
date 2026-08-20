# Secrets — NOT stored in Git

Kubernetes Secret name: **`aimarketing-secrets`** (namespace `aimarketing`)

Pods load it two ways:
1. **Environment** — `envFrom.secretRef` (same keys as your `.env`)
2. **Files** — mounted at `/etc/aimarketing/secrets/<KEY>` (one file per key)

## Where you put values

On your laptop only (gitignored / outside repo), create:

```text
~/aimarketing.secrets.env
```

Same KEY=value format as `deploy/.env.example`, but **only secret keys** (see `keys.env.example` in this folder).

## How to create the Secret in the cluster

### Option A — from your env file (recommended)

```bash
# needs kubectl pointing at the k3s cluster, OR use the SSM helper:
cd /Users/sandeshbafna/work/startup/cd-application
./scripts/apply-secrets.sh ~/aimarketing.secrets.env
```

### Option B — manual kubectl on the node

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl -n aimarketing create secret generic aimarketing-secrets \
  --from-env-file=/path/to/aimarketing.secrets.env \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Option C — one key at a time

```bash
kubectl -n aimarketing create secret generic aimarketing-secrets \
  --from-literal=POSTGRES_PASSWORD='...' \
  --from-literal=AUTH_JWT_SECRET='...' \
  ...
```

## Also required (not from this env file)

ECR pull secret (bootstrap already refreshes it):

```text
aimarketing / ecr-pull
```

## Do not

- Do not commit `*.secrets.env`
- Do not put passwords/API keys in `configmap.yaml`
