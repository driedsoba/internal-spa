#!/bin/bash

# Terraform Setup Validation Script
# This script helps validate your setup before running terraform

echo "Internal SPA - Setup Validation"
echo "=================================="

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo " terraform.tfvars file not found!"
    echo " Copy terraform.tfvars.example to terraform.tfvars and configure it"
    exit 1
else
    echo "terraform.tfvars file found"
fi

# Check if AWS CLI is configured
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found!"
    echo "   → Install AWS CLI and configure credentials"
    exit 1
else
    echo "AWS CLI found"
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "AWS credentials not configured or invalid!"
    echo "   → Run 'aws configure' to set up credentials"
    exit 1
else
    echo "AWS credentials configured"
    aws sts get-caller-identity --query 'Account' --output text | xargs echo "   Account ID:"
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found!"
    echo "   → Install Terraform from https://terraform.io"
    exit 1
else
    echo "Terraform found"
    terraform version | head -n 1
fi

# Check for Lambda source files
if [ ! -d "lambda" ]; then
    echo "Lambda source directory not found!"
    echo "   → Ensure lambda/ directory exists with Lambda function code"
    exit 1
else
    echo "Lambda source directory found"
    ls lambda/*.js lambda/*.mjs 2>/dev/null | wc -l | xargs echo "   Lambda files:"
fi

# Check terraform.tfvars for required values
echo ""
echo "Checking terraform.tfvars configuration..."

# Check if domain_name is customized
if grep -q "your-domain.com" terraform.tfvars; then
    echo "domain_name still has example value"
    echo "Update domain_name in terraform.tfvars"
fi

# Check if allowed_cidr_blocks is still default
if grep -q "0.0.0.0/0" terraform.tfvars; then
    echo "allowed_cidr_blocks is set to 0.0.0.0/0 (open to all)"
    echo " Consider restricting to your IP address for security"
fi

# Check if AWS region is set
REGION=$(grep "aws_region" terraform.tfvars | cut -d'"' -f2)
if [ ! -z "$REGION" ]; then
    echo "AWS region set to: $REGION"
else
    echo "AWS region not found in terraform.tfvars"
fi

echo ""
echo "Next Steps:"
echo "1. Review and customize terraform.tfvars"
echo "2. Run: terraform init"
echo "3. Run: terraform plan"
echo "4. Run: terraform apply"
echo ""
echo "For detailed instructions, see SETUP.md"