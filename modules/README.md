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

All modules are called from the root `main.tf` file with proper dependency management:

```hcl
# 1. Networking (foundation layer)
module "networking" {
  source = "./modules/networking"
  
  project_name         = var.project_name
  aws_region           = var.aws_region
  vpc_cidr             = "10.0.0.0/16"
  allowed_cidr_blocks  = var.allowed_cidr_blocks
  external_sg_id       = var.external_sg_id
}

# 2. Storage (independent)
module "storage" {
  source = "./modules/storage"
  
  project_name = var.project_name
  bucket_name  = var.domain_name
}

# 3. Compute (independent)
module "compute" {
  source = "./modules/compute"
  
  project_name        = var.project_name
  lambda_source_dir   = "${path.module}/lambda"
  lambda_runtime      = "nodejs22.x"
}

# 4. API Gateway (independent)
module "api_gateway" {
  source = "./modules/api-gateway"
  
  project_name = var.project_name
}

# 5. Load Balancer (depends on networking)
module "load_balancer" {
  source = "./modules/load-balancer"
  
  project_name          = var.project_name
  alb_security_group_id = module.networking.alb_security_group_id
  subnet_ids            = module.networking.subnet_ids
  vpc_id                = module.networking.vpc_id
}
```

## Module Dependencies

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  networking │    │   storage   │    │   compute   │
│ (foundation)│    │(independent)│    │(independent)│
└─────────────┘    └─────────────┘    └─────────────┘
       │                                      
       │            ┌─────────────┐           
       │            │ api_gateway │           
       │            │(independent)│           
       │            └─────────────┘           
       │                                      
       ▼                                      
┌─────────────┐                              
│load_balancer│                              
│ (depends on │                              
│ networking) │                              
└─────────────┘                              
```

**Deployment Order**: 
1. `networking`, `storage`, `compute`, `api_gateway` can be deployed in parallel
2. `load_balancer` must be deployed after `networking`

## Migration Notes

- **Original State**: All resources were in `generated.tf` (now backed up as `generated.tf.backup`)
- **Migration Process**: Used `terraform state mv` to move resources from root to module paths

### Key Migration Commands Used

```bash
# Example state moves performed:
terraform state mv aws_vpc.main module.networking.aws_vpc.main
terraform state mv aws_lambda_function.adminfilemanager module.compute.aws_lambda_function.admin_file_manager
terraform state mv aws_s3_bucket.spa_bucket module.storage.aws_s3_bucket.spa_bucket
```

### Post-Migration Validation

- `terraform plan` shows no changes after migration
- All interdependencies handled through module outputs/inputs
- Import blocks moved to `imports.tf.old` as backup