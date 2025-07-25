# Sentinel Policies

Governance policies for AWS infrastructure using HashiCorp Sentinel policy-as-code framework.

#### **iam-restrict-wildcards.sentinel**
- **Purpose**: Prevents IAM policies from using dangerous wildcard permissions
- **Enforcement Level**: `soft-mandatory`
- **Validations**:
  - Blocks wildcard actions: `*`, `s3:*`, `iam:*`, `ec2:*`, `lambda:*`
  - Scans IAM policies, role policies, and assume role policies
  - Provides detailed violation reporting with resource addresses
  - Helps maintain principle of least privilege

#### **s3-encryption-required.sentinel**
- **Purpose**: Ensures S3 buckets and EBS volumes have encryption enabled
- **Enforcement Level**: `soft-mandatory`
- **Validations**:
  - Requires S3 buckets to have server-side encryption configuration
  - Requires EBS volumes to have encryption enabled
  - Validates encryption is properly configured before deployment
  - Maintains data-at-rest security compliance
