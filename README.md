# Internal SPA

A simple file management system with AWS S3 integration for internal use.

## Overview

Web application for uploading and managing files across multiple S3 buckets. Includes an admin portal for bucket operations and file management.

## Project Structure
```
spa.chatwithjunle.com/           # Frontend files
├── index.html                   # File upload interface
└── admin.html                   # Admin portal
lambda/                          # AWS Lambda functions
├── DirectS3Upload.mjs           # Generate upload URLs
├── AdminFileManager.mjs         # File operations
├── BucketAdministrator.mjs      # Bucket management
└── ListS3Buckets.mjs            # List available buckets
README.md
```

## Features

- **File Upload**: Drag & drop files to S3 buckets
- **File Management**: List, delete, and move files between buckets
- **Bucket Admin**: Create buckets, set policies, configure lifecycle rules
- **Secure Access**: Private network access via ALB + S3 Interface Endpoint

## Architecture

- Frontend hosted on S3, served via ALB
- 4 Lambda functions handle backend operations
- Direct S3 uploads using pre-signed URLs
- Automatically discovers and manages buckets starting with `spa-s3-`

## Quick Setup

1. Deploy Lambda functions with S3 permissions
2. Set up API Gateway with CORS for spa.chatwithjunle.com
3. Configure ALB to redirect `/` → `/index.html`
4. Upload frontend files to S3 hosting bucket
5. Access at `https://spa.chatwithjunle.com`

## Lambda Functions

- **DirectS3Upload**: `POST /upload-url` - Get pre-signed upload URLs
- **AdminFileManager**: `POST /admin/files` - File operations (list/delete/move)
- **BucketAdministrator**: `POST /admin/buckets` - Bucket management
- **ListS3Buckets**: `GET /buckets` - List available buckets

## Configuration

**Required S3 Permissions:**
- GetObject, PutObject, DeleteObject
- ListBucket, CreateBucket, DeleteBucket
- GetBucketPolicy, PutBucketPolicy
- PutLifecycleConfiguration

**CORS Settings:**
Origin: https://spa.chatwithjunle.com
Headers: Content-Type, X-Amz-Date
Methods: GET, POST, OPTIONS

## License

MIT