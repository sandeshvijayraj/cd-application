# Public URLs (no purchased domain)

Google OAuth rejects bare IPs. Options:

| Hostname | Usable for Google? |
|----------|--------------------|
| `43.204.166.111` | No |
| `ip-….compute.internal` | No (VPC-only) |
| `ec2-….compute.amazonaws.com` | Yes (AWS public DNS) |
| Own domain (Route 53) | Yes (optional later) |

## Current

Frontend: http://ec2-43-204-166-111.ap-south-1.compute.amazonaws.com:30080  
Backend: http://ec2-43-204-166-111.ap-south-1.compute.amazonaws.com:30800  
