# Sentinel Policy Configuration for Internal SPA Infrastructure
# CIS (Center for Internet Security) AWS Terraform Policy Set

# EC2 Security Group IPv4 Ingress Traffic Restriction
# Ensures security groups don't allow unrestricted ingress traffic
policy "ec2-security-group-ipv4-ingress-traffic-restriction" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy/ec2-security-group-ipv4-ingress-traffic-restriction.sentinel?checksum=sha256:2d8d050ae6dfa51f9f7ffa39b9059c70d2cba459ff89639baef49978fc447811"
  enforcement_level = "advisory"
}

# EC2 EBS Encryption Enabled
# Ensures EBS volumes are encrypted
policy "ec2-ebs-encryption-enabled" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy/ec2-ebs-encryption-enabled.sentinel?checksum=sha256:ad0d6f7f068396d0cadd55dbb665b0379d232f4122ab62e674f263b2eb762dba"
  enforcement_level = "advisory"
}

# S3 Block Public Access at Account Level
# Ensures S3 account-level public access is blocked
policy "s3-block-public-access-account-level" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy/s3-block-public-access-account-level.sentinel?checksum=sha256:fe9b5590e1f1c80aea63ad14c278f65c2d9a090d50e42f808f7480df229e84b6"
  enforcement_level = "advisory"
}

# S3 Block Public Access at Bucket Level
# Ensures S3 bucket-level public access is blocked (you already have this implemented!)
policy "s3-block-public-access-bucket-level" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy/s3-block-public-access-bucket-level.sentinel?checksum=sha256:38cb17fd70b9e87bbc3283cc720458965dca75fc6074c159d301d6f901443ae1"
  enforcement_level = "advisory"
}

# IAM No Admin Privileges Allowed by Policies
# Prevents creation of overly permissive IAM policies
policy "iam-no-admin-privileges-allowed-by-policies" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy/iam-no-admin-privileges-allowed-by-policies.sentinel?checksum=sha256:55e4852d49635fdaba4220678c7fc9297c529cb910428a8f47a3c06d6fe9ea99"
  enforcement_level = "advisory"
}

# Required Modules for CIS Policy Set
module "report" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy-module/report.sentinel?checksum=sha256:1f414f31c2d6f7e4c3f61b2bc7c25079ea9d5dd985d865c01ce9470152fa696d"
}

module "tfresources" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy-module/tfresources.sentinel?checksum=sha256:5b91f0689dd6d68d17bed2612cd72127a6dcfcedee0e2bb69a617ded71ad0168"
}

module "tfplan-functions" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy-module/tfplan-functions.sentinel?checksum=sha256:e7f04948ec53d7c01ff26829c1ef7079fb072ed5074483f94dd3d00ae5bb67b3"
}

module "tfconfig-functions" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-Terraform/1.0.1/policy-module/tfconfig-functions.sentinel?checksum=sha256:ee1c5baf3c2f6b032ea348ce38f0a93d54b6e5337bade1386fffb185e2599b5b"
}
