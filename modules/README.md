# Terraform Modules

This directory contains the modularized Terraform configuration for the internal SPA project.

## Module Structure

### `networking/`
- **Purpose**: Manages VPC, subnets, security groups, and VPC endpoints
- **Resources**: 
  - VPC with DNS support
  - Private subnets across multiple AZs
  - Security groups for ALB and S3 interface endpoint
  - S3 VPC interface endpoint
- **Outputs**: VPC ID, subnet IDs, security group IDs

### `compute/`
- **Purpose**: Manages Lambda functions and their IAM roles
- **Resources**:
  - Lambda function packaging (zip files)
  - IAM roles with assume role policies
  - Lambda functions (AdminFileManager, BucketAdministrator, DirectS3Upload, ListS3Buckets)
- **Outputs**: Lambda function ARNs and names, IAM role ARNs

### `storage/`
- **Purpose**: Manages S3 buckets and related storage resources
- **Resources**:
  - S3 bucket for the SPA
- **Outputs**: Bucket ID, ARN, and domain name

### `api-gateway/`
- **Purpose**: Manages API Gateway for the application
- **Resources**:
  - REST API Gateway with regional endpoint
- **Outputs**: API Gateway ID, execution ARN, root resource ID

### `load-balancer/`
- **Purpose**: Manages Application Load Balancer and target groups
- **Resources**:
  - Application Load Balancer
  - Target group with health checks
- **Outputs**: ALB DNS name, zone ID, target group ARN

## Usage

All modules are called from the root `main.tf` file:

```hcl
module "networking" {
  source = "./modules/networking"
  # ... variables
}

module "compute" {
  source = "./modules/compute"
  # ... variables
}

# ... other modules
```

## Migration Notes

- The original `generated.tf` file has been renamed to `generated.tf.backup`
- All resources are now managed through modules for better organization
- Each module has its own variables, outputs, and main configuration
- Module interdependencies are handled through outputs and inputs