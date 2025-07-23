# Sentinel Policy Configuration for Internal SPA Infrastructure

policy "ec2-ebs-encryption-enabled" {
  source = "./policies/ec2-ebs-encryption-enabled.sentinel"
  enforcement_level = "advisory"
}

policy "ec2-security-group-ingress-traffic-restriction-port-22" {
  source = "./policies/ec2-security-group-ingress-traffic-restriction-port-22.sentinel"
  enforcement_level = "advisory"
}

policy "iam-no-admin-privileges" {
  source = "./policies/iam-no-admin-privileges.sentinel"
  enforcement_level = "advisory"
}

policy "s3-block-public-access-account-level" {
  source = "./policies/s3-block-public-access-account-level.sentinel"
  enforcement_level = "advisory"
}

policy "s3-block-public-access-bucket-level" {
  source = "./policies/s3-block-public-access-bucket-level.sentinel"
  enforcement_level = "advisory"
}