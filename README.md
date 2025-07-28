# S3 SPA Infrastructure

A Terraform-managed file management system with AWS S3 integration for internal use.

## Quick Start

**New to this project?** → See [SETUP.md](SETUP.md) for complete deployment instructions.

**Existing users?** → Continue reading for architecture details and maintenance information.

## Overview

This project provides a web application for uploading and managing files across multiple S3 buckets, featuring an admin portal for bucket operations and file management. The infrastructure is fully managed with Terraform using a modular architecture.

## Architecture Diagram
![Architecture Diagram](S3-SPA.png)

### Key Components

- **VPC Network**: Private subnets across multiple AZs with S3 VPC endpoint for secure access
- **Application Load Balancer**: External-facing ALB serving the frontend
- **Lambda Functions**: Serverless backend for file operations and bucket management
- **API Gateway**: RESTful API interface for Lambda functions
- **S3 Storage**: Primary bucket for hosting and multiple buckets for file management

## Project Structure

```
internal-spa/
├── frontend/                   # Frontend static files
│   ├── index.html              # File upload interface
│   └── admin.html              # Admin portal
├── lambda/                     # AWS Lambda functions source
│   ├── DirectS3Upload.js       # Generate pre-signed upload URLs
│   ├── AdminFileManager.mjs    # File operations (list/delete/move)
│   ├── BucketAdministrator.mjs # Bucket management
│   └── ListS3Buckets.mjs       # List available buckets
├── modules/                    # Terraform modules
│   ├── networking/             # VPC, subnets, security groups
│   ├── compute/                # Lambda functions and IAM roles
│   ├── storage/                # S3 buckets
│   ├── api-gateway/            # API Gateway configuration
│   └── load-balancer/          # ALB and target groups
├── sentinel/                   # Sentinel governance policies
│   ├── sentinel.hcl            # Policy configuration
│   ├── policies/               # Policy implementation files
│   │   ├── iam-restrict-wildcards.sentinel
│   │   └── s3-encryption-required.sentinel
│   └── README.md               # Policy documentation
├── lambda-packages/            # Generated Lambda deployment packages
├── main.tf                     # Root Terraform configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── terraform.tfvars            # Variable values
├── terraform.tfvars.example    # Example variable configuration
├── generated.tf.backup         # Legacy monolithic config (backup)
└── imports.tf.backup           # Original import blocks (backup)
```

## Terraform Modules

### Module Structure

#### `modules/networking/`
- VPC with DNS support and hostnames
- Private subnets in multiple availability zones
- Security groups for ALB and S3 access
- S3 VPC interface endpoint for private connectivity

#### `modules/compute/`
- Lambda function packaging and deployment
- IAM roles with **least-privilege policies** for enhanced security
- Four Lambda functions for different operations:
  - `DirectS3Upload`: Minimal S3 permissions (ListAllMyBuckets, PutObject)
  - `AdminFileManager`: File operations (List, Get, Put, Delete, GetObjectAttributes)
  - `BucketAdministrator`: Bucket management operations only
  - `ListS3Buckets`: Read-only bucket listing
- Dynamic CloudWatch logging policies with region/account-specific ARNs

#### `modules/storage/`
- S3 bucket for frontend hosting
- Bucket policies and configurations

#### `modules/api-gateway/`
- REST API Gateway with regional endpoints
- CORS configuration for frontend domain

#### `modules/load-balancer/`
- Application Load Balancer
- Target groups with health checks
- SSL/TLS termination

### Migration Process

1. **Infrastructure Import**: Used `terraform import` blocks to bring existing AWS resources under Terraform management
2. **State Generation**: Generated initial configuration with `terraform plan -generate-config-out=generated.tf`
3. **Modularization**: Split monolithic configuration into logical modules
4. **State Migration**: Used `terraform state mv` to move resources from root to module paths

### Migration Commands Used

```bash
# Move VPC resources to networking module
terraform state mv aws_vpc.main module.networking.aws_vpc.main
terraform state mv aws_subnet.private_1a module.networking.aws_subnet.private_1a

# Move Lambda resources to compute module
terraform state mv aws_lambda_function.adminfilemanager module.compute.aws_lambda_function.adminfilemanager

# Move S3 resources to storage module
terraform state mv aws_s3_bucket.spa_bucket module.storage.aws_s3_bucket.spa_bucket

# And so on for all resources...
```

## Application Features

- **File Upload**: Drag & drop interface with direct S3 uploads via pre-signed URLs
- **File Management**: List, delete, and move files between buckets
- **Bucket Administration**: Create buckets, set policies, configure lifecycle rules
- **Secure Access**: Private network access via ALB and S3 VPC endpoint
- **Auto-Discovery**: Automatically discovers and manages buckets with `spa-s3-` prefix  
- **Security Compliance**: Implements Sentinel policies for IAM and encryption governance
- **Least-Privilege Access**: Function-specific IAM policies with minimal required permissions

## API Endpoints

### Public Endpoints
- `GET /buckets` - List available S3 buckets
- `POST /upload-url` - Generate pre-signed upload URLs

### Admin Endpoints
- `POST /admin/files` - File operations (list/delete/move)
- `POST /admin/buckets` - Bucket management operations

## Security & Governance

This project implements **Sentinel policies** for automated compliance and security validation.

### Current Policies

#### **IAM Wildcard Restriction**
- **Enforcement Level**: `soft-mandatory`
- **Validations**:
  - Blocks wildcards: `*`, `s3:*`, `iam:*`, `ec2:*`, `lambda:*`
  - Scans IAM policies, role policies, and assume role policies

#### **S3 Encryption Required**
- **Enforcement Level**: `soft-mandatory`
- **Validations**:
  - Requires S3 server-side encryption configuration
  - Validates encryption before deployment
  
## Deployment

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Node.js runtime for Lambda functions

### Deploy Infrastructure

1. **Configure Variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan Deployment**:
   ```bash
   terraform plan
   ```

4. **Apply Configuration**:
   ```bash
   terraform apply
   ```

   **Note**: During deployment, Terraform will evaluate Sentinel policies for security compliance. All policies must pass for successful deployment.

5. **Upload Frontend Files**:
   ```bash
   aws s3 sync frontend/ s3://your-domain-name/
   ```

### Required AWS Permissions

The Lambda functions now use **least-privilege IAM policies** with these specific permissions:

#### DirectS3Upload Function
- `s3:ListAllMyBuckets` - Discover available buckets
- `s3:PutObject` - Upload files to target bucket
- `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` - CloudWatch logging

#### AdminFileManager Function  
- `s3:ListAllMyBuckets` - Bucket discovery
- `s3:ListBucket` - List objects in bucket
- `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` - File operations
- `s3:GetObjectAttributes` - File metadata
- `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` - CloudWatch logging

#### BucketAdministrator Function
- `s3:CreateBucket`, `s3:DeleteBucket` - Bucket lifecycle
- `s3:GetBucketPolicy`, `s3:PutBucketPolicy`, `s3:DeleteBucketPolicy` - Policy management
- `s3:GetBucketLifecycleConfiguration`, `s3:PutBucketLifecycleConfiguration` - Lifecycle rules
- `s3:GetBucketCors`, `s3:PutBucketCors` - CORS configuration
- `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` - CloudWatch logging

#### ListS3Buckets Function
- `s3:ListAllMyBuckets` - List available buckets only
- `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` - CloudWatch logging

**Note**: All permissions are scoped to the specific bucket `spa.chatwithjunle.com` except for bucket listing operations.

## Configuration

### CORS Settings
- **Origin**: `https://spa.chatwithjunle.com`
- **Headers**: `Content-Type`, `X-Amz-Date`, `Authorization`
- **Methods**: `GET`, `POST`, `OPTIONS`

### Environment Variables
- `AWS_REGION`: Target AWS region (default: ap-southeast-1)
- `PROJECT_NAME`: Project identifier for resource naming
- `DOMAIN_NAME`: Frontend domain name

## License

MIT
