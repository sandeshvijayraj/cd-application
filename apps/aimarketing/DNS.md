# DNS / public URLs

## Why not the raw IP?

Google OAuth **rejects** origins like `http://43.204.166.111:30080`
(“must end with a public top-level domain”).

## Current (free): nip.io + NodePorts

`app.43.204.166.111.nip.io` and `api.43.204.166.111.nip.io` resolve to the EIP.

| App | URL |
|-----|-----|
| Frontend | http://app.43.204.166.111.nip.io:30080 |
| Backend API | http://api.43.204.166.111.nip.io:30800 |

## Later: your own domain on AWS (Route 53)

1. Buy/register a domain: https://console.aws.amazon.com/route53/home  
2. Create **A** records → `43.204.166.111` (e.g. `app.yourdomain.com`, `api.yourdomain.com`)  
3. Install an Ingress controller (Traefik/nginx) on k3s so traffic uses **:80/:443** without NodePorts  
4. Update ConfigMap + secrets + Google/Meta console URLs  
5. Add HTTPS (Let's Encrypt)

Tell us the domain name you want and we can wire Route 53 + Ingress.
