# cd-application

GitOps manifests for Argo CD. **No secret values in this repo.**

## Deploy flow (always)

```text
ai_marketing (main)
        │  merge / ship on main only
        ▼
git tag release/vX.Y.Z && git push origin release/vX.Y.Z
        │
        ▼
GitHub Actions "ecr-on-tag" → ECR aimarketing-*:vX.Y.Z
        │  wait until green
        ▼
cd-application: ./scripts/set-release-tag.sh vX.Y.Z
        │  commit + push main
        ▼
Argo CD (aimarketing) auto-sync → cluster
```

Do **not** deploy by pushing image tags from feature branches. Cut tags from `main` only.

### Commands

```bash
# 1) App repo — on main, after merge
cd ai_marketing
git checkout main && git pull
git tag release/v0.1.1
git push origin release/v0.1.1
# wait: https://github.com/sandeshvijayraj/ai_marketing/actions

# 2) GitOps — pin the same version
cd cd-application
./scripts/set-release-tag.sh v0.1.1
git add apps/aimarketing/*/deployment.yaml
git commit -m "Deploy v0.1.1"
git push origin main
```

Argo Application source: this repo, path `apps/aimarketing`, branch `main`.

## Persistence

| Data | PVC | Mount |
|------|-----|--------|
| Postgres | `postgres-data` (10Gi) | `/var/lib/postgresql/data` |
| Redis | `redis-data` (5Gi, AOF) | `/data` |

PVCs use the cluster default StorageClass (k3s `local-path` on the bare-metal node). Data survives pod restarts; it is still node-local (backup separately if you need DR).

## Layout

```text
apps/aimarketing/
  kustomization.yaml
  namespace.yaml
  configmap.yaml          # non-secret env
  backend/ frontend/ scheduler/ postgres/ redis/
  secrets/                # docs only — values never committed
```

## Secrets (cluster only)

See `apps/aimarketing/secrets/README.md`.

```bash
./scripts/apply-secrets.sh ~/aimarketing.secrets.env
```
