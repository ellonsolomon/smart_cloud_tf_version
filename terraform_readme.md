# AWS Serverless Photo Gallery - Terraform Implementation

This Terraform configuration deploys a complete serverless photo gallery application on AWS, including:

- **S3 Bucket** for photo storage with CORS configuration
- **DynamoDB Table** for photo metadata with GSI
- **Lambda Functions** for photo operations (list, upload, delete)
- **API Gateway** with proper CORS setup
- **IAM Roles and Policies** with least privilege access

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Client    │───▶│ API Gateway │───▶│   Lambda    │───▶│  DynamoDB   │
│ (Frontend)  │    │   (CORS)    │    │ Functions   │    │   Table     │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                  │
                          ▼                  ▼
                   ┌─────────────┐    ┌─────────────┐
                   │     S3      │    │ CloudWatch  │
                   │   Bucket    │    │    Logs     │
                   └─────────────┘    └─────────────┘
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** v1.0+ installed
3. **AWS Account** with necessary permissions

### Required AWS Permissions

Your AWS credentials need the following services permissions:
- S3 (CreateBucket, PutBucketCors, etc.)
- DynamoDB (CreateTable, etc.)
- Lambda (CreateFunction, UpdateFunctionCode, etc.)
- API Gateway (CreateRestApi, CreateResource, etc.)
- IAM (CreateRole, AttachRolePolicy, etc.)
- CloudWatch (CreateLogGroup, etc.)

## File Structure

```
.
├── main.tf                    # Main configuration and providers
├── variables.tf              # Input variables
├── outputs.tf                # Output values
├── iam.tf                    # IAM roles and policies
├── dynamodb.tf               # DynamoDB table configuration
├── s3.tf                     # S3 bucket configuration
├── lambda.tf                 # Lambda functions
├── api_gateway.tf            # API Gateway configuration
├── terraform.tfvars.example  # Example variables file
├── README.md                 # This file
└── lambda_functions/         # Lambda function source code
    ├── list.py              # List photos function
    ├── upload.py            # Upload photos function
    └── delete.py            # Delete photos function
```

## Quick Start

### 1. Clone and Prepare

```bash
# Create project directory
mkdir photo-gallery-terraform
cd photo-gallery-terraform

# Copy all .tf files to this directory
# Copy lambda_functions/ directory with Python files
```

### 2. Configure Variables

```bash
# Copy the example variables file
cp terraform.tfvars terraform.tfvars

# Edit terraform.tfvars with your desired configuration
nano terraform.tfvars
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the execution plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Get API Endpoint

```bash
# Get the API endpoint URL
terraform output api_endpoint

# Example output:
# "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod"
```

## Configuration Options

### Core Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `region` | AWS region | `us-east-1` | No |
| `project_name` | Project name for resource naming | `photo-gallery` | No |
| `environment` | Environment (dev/staging/prod) | `prod` | No |

### DynamoDB Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `dynamodb_table_name` | DynamoDB table name | `PhotoGallery` |
| `dynamodb_read_capacity` | Read capacity units | `5` |
| `dynamodb_write_capacity` | Write capacity units | `5` |

### Lambda Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `lambda_timeout` | Function timeout (seconds) | `30` |
| `lambda_memory_size` | Memory size (MB) | `128` |

### CORS Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cors_allowed_origins` | Allowed origins | `["*"]` |
| `cors_allowed_headers` | Allowed headers | `["Content-Type", ...]` |

## API Endpoints

After deployment, your API will have the following endpoints:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/photos` | List all photos |
| `HEAD` | `/photos` | Connection test |
| `POST` | `/photos` | Get upload URL |
| `DELETE` | `/photos/{photoId}` | Delete a photo |
| `OPTIONS` | `/photos` | CORS preflight |
| `OPTIONS` | `/photos/{photoId}` | CORS preflight |

### Query Parameters for GET /photos

- `?tag=vacation` - Filter by tag
- `?search=beach` - Search in titles
- `?limit=20` - Limit results (default: 50)

## Usage Examples

### List Photos
```bash
curl -X GET "https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/photos"
```

### Get Upload URL
```bash
curl -X POST "https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/photos" \
  -H "Content-Type: application/json" \
  -d '{
    "filename": "vacation.jpg",
    "contentType": "image/jpeg",
    "title": "Beach Vacation",
    "tags": ["vacation", "beach"],
    "size": 1024000
  }'
```

### Delete Photo
```bash
curl -X DELETE "https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/photos/photo-id-here"
```

## Monitoring and Logs

All Lambda functions automatically create CloudWatch Log Groups:
- `/aws/lambda/photo-gallery-list`
- `/aws/lambda/photo-gallery-upload`
- `/aws/lambda/photo-gallery-delete`

## Security Features

- **IAM Least Privilege**: Lambda functions have minimal required permissions
- **CORS Configured**: Proper CORS headers for web applications  
- **S3 Security**: Public access blocked, presigned URLs for access
- **Encryption**: S3 and DynamoDB encryption enabled

## Cost Optimization

- **DynamoDB**: Uses provisioned capacity (can be changed to on-demand)
- **Lambda**: Pay per request pricing
- **S3**: Standard storage class (can be optimized with lifecycle policies)
- **CloudWatch**: 7-day log retention to minimize costs

## Customization

### Changing Lambda Memory/Timeout
```hcl
# In terraform.tfvars
lambda_memory_size = 256
lambda_timeout = 60
```

### Adding Additional CORS Origins
```hcl
# In terraform.tfvars
cors_allowed_origins = ["https://yourdomain.com", "https://www.yourdomain.com"]
```

### Custom Tags
```hcl
# In terraform.tfvars
tags = {
  Project     = "MyPhotoApp"
  Environment = "production"
  Owner       = "john.doe@company.com"
  CostCenter  = "engineering"
}
```

## Troubleshooting

### Common Issues

1. **AWS Credentials**: Ensure AWS CLI is configured correctly
   ```bash
   aws sts get-caller-identity
   ```

2. **Terraform State**: If deployment fails, check state file
   ```bash
   terraform show
   terraform refresh
   ```

3. **Lambda Permissions**: Check CloudWatch logs for permission errors

4. **CORS Issues**: Verify preflight requests are working:
   ```bash
   curl -X OPTIONS "https://your-api/prod/photos" -H "Origin: http://localhost:3000"
   ```

### Cleanup

To remove all resources:
```bash
terraform destroy
```

**Warning**: This will delete all data including photos and metadata!

## Integration with Frontend

Update your frontend application with the API endpoint:

```javascript
// In your frontend code
const API_BASE_URL = 'https://your-api-id.execute-api.us-east-1.amazonaws.com/prod';

// Example usage
const response = await fetch(`${API_BASE_URL}/photos`);
const data = await response.json();
```

## Advanced Configuration

### Multiple Environments

Create environment-specific `.tfvars` files:

```bash
# For staging
terraform apply -var-file="staging.tfvars"

# For production  
terraform apply -var-file="production.tfvars"
```

### State Management

For production use, consider using remote state:

```hcl
# Add to main.tf
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "photo-gallery/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Support

If you encounter issues:

1. Check the [Terraform AWS Provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
2. Review CloudWatch logs for Lambda function errors
3. Verify AWS permissions and service quotas
4. Check AWS service status for outages

## License

This Terraform configuration is provided as-is for educational and commercial use.