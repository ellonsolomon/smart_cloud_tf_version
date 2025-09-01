import json
import boto3
from boto3.dynamodb.conditions import Key, Attr
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')
table = dynamodb.Table('${table_name}')

BUCKET_NAME = os.environ['BUCKET_NAME']


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            if float(obj).is_integer():
                return int(obj)
            else:
                return float(obj)
        return super(DecimalEncoder, self).default(obj)


def lambda_handler(event, context):
    try:
        # Handle CORS preflight
        if event.get('httpMethod') == 'OPTIONS':
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS, HEAD'
                },
                'body': ''
            }

        # Handle HEAD request for connection test
        if event.get('httpMethod') == 'HEAD':
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS, HEAD'
                },
                'body': ''
            }

        # Get query parameters
        query_params = event.get('queryStringParameters') or {}
        filter_tag = query_params.get('tag')
        search_term = query_params.get('search')
        limit = int(query_params.get('limit', 50))

        # Scan DynamoDB table
        if filter_tag:
            response = table.scan(
                FilterExpression=Attr('tags').contains(filter_tag),
                Limit=limit
            )
        elif search_term:
            response = table.scan(
                FilterExpression=Attr('title').contains(search_term),
                Limit=limit
            )
        else:
            response = table.scan(Limit=limit)

        # Generate presigned URLs for images
        photos = []
        for item in response.get('Items', []):
            # Generate presigned URL for viewing
            image_url = None
            if item.get('s3Key'):
                try:
                    image_url = s3.generate_presigned_url(
                        'get_object',
                        Params={'Bucket': BUCKET_NAME, 'Key': item['s3Key']},
                        ExpiresIn=3600
                    )
                except:
                    pass

            photos.append({
                'photoId': item.get('photoId', ''),
                'title': item.get('title', ''),
                'imageUrl': image_url,
                'uploadDate': item.get('uploadDate', ''),
                'tags': item.get('tags', []),
                'size': int(item.get('size', 0)) if item.get('size') else 0,
                'filename': item.get('filename', '')
            })

        # Sort by upload date (newest first)
        photos.sort(key=lambda x: x.get('uploadDate', ''), reverse=True)

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'GET, POST, OPTIONS, HEAD',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'photos': photos,
                'count': len(photos)
            }, cls=DecimalEncoder)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': str(e)})
        }
