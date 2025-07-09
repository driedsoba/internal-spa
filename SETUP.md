# Deployment Setup Guide

This guide will help you deploy the Internal SPA infrastructure in your own AWS account.

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with your credentials
3. **Terraform** installed
4. **Node.js** for Lambda function packaging

## Required AWS Permissions

Your AWS user/role needs the following permissions:
- EC2 (VPC, Subnets, Security Groups, Endpoints)
- S3 (Buckets, Policies, Objects)
- Lambda (Functions, Layers, Roles)
- IAM (Roles, Policies, Attachments)
- API Gateway (APIs, Methods, Deployments)
- Application Load Balancer (ALB, Target Groups)
- CloudWatch (Log Groups)

## Quick Setup

### 1. Clone and Configure

```bash
git clone <repository-url>
cd internal-spa

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Configuration

Edit `terraform.tfvars` with your specific values:

```hcl
# Application Configuration
aws_region   = "us-east-1"              # Your preferred AWS region
environment  = "dev"                    # Your environment name
domain_name  = "your-domain.com"        # Your domain name
project_name = "your-project-name"      # Your project identifier

# Network Configuration - IMPORTANT: Restrict this!
allowed_cidr_blocks = ["YOUR_IP/32"]    # Replace with your public IP

# Optional: Reference existing security group
# external_sg_id = "sg-xxxxxxxxx"       # If you have an existing SG
```

**Security Note**: Replace `YOUR_IP` with your actual public IP address. You can find it by running:
```bash
curl ifconfig.me/ip
```

### 3. Choose Backend Configuration

#### Option A: Local State (Simplest)
Leave the backend configuration commented out in `main.tf`. State will be stored locally.

#### Option B: Terraform Cloud
1. Create a Terraform Cloud account at https://app.terraform.io
2. Create an organization and workspace
3. Uncomment the cloud block in `main.tf`:
```hcl
terraform {
  cloud {
    organization = "your-org-name"
    workspaces {
      name = "your-workspace-name"
    }
  }
}
```

#### Option C: S3 Backend
1. Create an S3 bucket for Terraform state
2. Uncomment the S3 backend in `main.tf`:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "internal-spa/terraform.tfstate"
    region = "your-region"
  }
}
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 5. Upload Frontend Files

After successful deployment, upload the frontend files:

```bash
# Get the S3 bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload frontend files
aws s3 sync frontend/ s3://$BUCKET_NAME/
```

### 6. Access Your Application

Your application will be available at the ALB DNS name shown in the Terraform output.

## Customization Options

### Network Configuration

- **VPC CIDR**: Default is `10.0.0.0/16`
- **Subnets**: Private subnets in 2 AZs
- **Security Groups**: ALB and S3 endpoint access

### Lambda Configuration

- **Runtime**: Node.js 22.x
- **Memory**: 128 MB (configurable)
- **Timeout**: 3 seconds (configurable)

### Domain and SSL

To use a custom domain:
1. Configure Route 53 hosted zone
2. Request/import SSL certificate in ACM
3. Update ALB listener configuration

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure your AWS credentials have sufficient permissions
   - Check IAM policies and resource-based policies

2. **Resource Already Exists**
   - Check for naming conflicts
   - Verify the region is correct

3. **Backend Configuration**
   - Ensure Terraform Cloud/S3 bucket exists and is accessible
   - Check authentication for remote backends

4. **Lambda Deployment**
   - Ensure Lambda source files exist in `lambda/` directory
   - Check Node.js compatibility

### Getting Help

- Check Terraform plan output for detailed error messages
- Review AWS CloudTrail for permission issues
- Validate your `terraform.tfvars` configuration

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Note**: This will delete all resources. Ensure you have backups of any important data stored in S3 buckets.