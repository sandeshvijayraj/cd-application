# Public HTTPS (CloudFront)

Stack: `aimarketing-cloudfront` (us-east-1)

| | URL |
|--|-----|
| App | https://da88yiprffut6.cloudfront.net |
| Google redirect | https://da88yiprffut6.cloudfront.net/api/auth/callback/google |
| Meta/Instagram redirect | https://da88yiprffut6.cloudfront.net/api/v1/integrations/meta/callback |

Uses free default `*.cloudfront.net` certificate (no purchased domain).
Origin = EC2 public DNS NodePorts. App NodePorts are open to the internet so CloudFront can fetch; SSH/Argo stay WiFi-locked.
