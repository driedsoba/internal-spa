# Sentinel Policies

CIS (Center for Internet Security) AWS Terraform policies for governance and compliance.

## Policies

- **ec2-security-group-ipv4-ingress-traffic-restriction**: Prevents unrestricted ingress traffic
- **ec2-ebs-encryption-enabled**: Ensures EBS volumes are encrypted  
- **s3-block-public-access-account-level**: Blocks S3 public access at account level
- **s3-block-public-access-bucket-level**: Blocks S3 public access at bucket level 
- **iam-no-admin-privileges-allowed-by-policies**: Prevents overly permissive IAM policies

All policies are set to `advisory` enforcement level.

## Setup

Configure in Terraform Cloud:
1. Go to workspace Settings → Policy Sets
2. Create new policy set with source: Version Control System  
3. Directory: `sentinel/`
