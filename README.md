# cd-application

GitOps manifests for Argo CD. **No secret values in this repo.**

Argo CD syncs `apps/aimarketing` → cluster namespace `aimarketing`.

## Layout

```text
apps/aimarketing/
  kustomization.yaml
  namespace.yaml
  configmap.yaml          # non-secret env (edit here)
  backend/ frontend/ scheduler/ postgres/ redis/
  secrets/                # docs + empty key list only
```

## Secrets (you create on the cluster)

See `apps/aimarketing/secrets/README.md`.

Put values in a **local** file (never commit), e.g. on your laptop:

`~/aimarketing.secrets.env`

Then apply (from a machine with kubectl / SSM to the node):

```bash
./scripts/apply-secrets.sh ~/aimarketing.secrets.env
```

## Wire Argo CD to this repo

After you create `https://github.com/sandeshvijayraj/cd-application`:

1. Push this folder to that repo (`main`).
2. Register the private repo with Argo CD (PAT), same as before.
3. Apply Application CR (in this repo: `argocd/application.yaml`).

```bash
git remote add origin git@github.com:sandeshvijayraj/cd-application.git
git push -u origin main
```
