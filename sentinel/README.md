# Sentinel Policies

Security policies for AWS infrastructure governance.

## Policies

- **ec2-security-group-restriction**: Prevents unrestricted ingress traffic
- **s3-block-public-access**: Ensures S3 bucket public access is blocked
- **iam-no-admin-privileges**: Prevents overly permissive IAM policies

All policies are set to `advisory` enforcement level.

## Setup in Terraform Cloud

1. Go to workspace Settings → Policy Sets
2. Create new policy set: **Upload files**
3. Upload all files from `sentinel/` directory
4. Apply to workspace: `internal-spa`
