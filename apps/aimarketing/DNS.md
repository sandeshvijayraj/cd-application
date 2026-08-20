# DNS / public URLs

Google (and often Meta) **reject bare IP origins** like `http://43.204.166.111:30080`.
You need a hostname that ends in a real TLD (`.com`, `.io`, etc.).

## Current (free): nip.io

`*.43.204.166.111.nip.io` resolves to the node EIP. Traefik Ingress serves:

| Host | Service |
|------|---------|
| http://app.43.204.166.111.nip.io | frontend |
| http://api.43.204.166.111.nip.io | backend |

## Later (recommended): Route 53 domain

1. Buy a domain in [Route 53 Domains](https://console.aws.amazon.com/route53/home) (or transfer one in).
2. Create an **A** record → `43.204.166.111` (and maybe `api.` / `app.` subdomains).
3. Update `apps/aimarketing/configmap.yaml` + Ingress hosts + cluster secrets.
4. Optionally add HTTPS (Traefik + Let's Encrypt / ACM).

Until then, use the nip.io URLs in Google / Meta consoles.
