import json
import boto3
import uuid
from datetime import datetime
import os
from decimal import Decimal

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('${table_name}')

BUCKET_NAME = os.environ['BUCKET_NAME']


def lambda_handler(event, context):
    try:
        # Handle CORS preflight
        if event.get('httpMethod') == 'OPTIONS':
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
                },
                'body': ''
            }

        # Parse request body
        body = json.loads(event.get('body', '{}'))
        filename = body.get('filename', 'unknown.jpg')
        content_type = body.get('contentType', 'image/jpeg')

        # Generate unique photo ID and S3 key
        photo_id = str(uuid.uuid4())
        s3_key = f"photos/{photo_id}_{filename}"

        # Generate presigned URL for upload
        presigned_url = s3.generate_presigned_url(
            'put_object',
            Params={
                'Bucket': BUCKET_NAME,
                'Key': s3_key,
                'ContentType': content_type
            },
            ExpiresIn=3600
        )

        # Store metadata in DynamoDB
        table.put_item(
            Item={
                'photoId': photo_id,
                'filename': filename,
                's3Key': s3_key,
                'contentType': content_type,
                'uploadDate': datetime.now().isoformat(),
                'title': body.get('title', filename),
                'tags': body.get('tags', []),
                'size': Decimal(str(body.get('size', 0)))
            }
        )

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'photoId': photo_id,
                'uploadUrl': presigned_url,
                's3Key': s3_key
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }
