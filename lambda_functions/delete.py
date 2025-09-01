import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')
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
                    'Access-Control-Allow-Methods': 'DELETE, OPTIONS'
                },
                'body': ''
            }

        # Get photo ID from path parameters
        path_params = event.get('pathParameters', {})
        photo_id = path_params.get('photoId')

        if not photo_id:
            return {
                'statusCode': 400,
                'headers': {'Access-Control-Allow-Origin': '*'},
                'body': json.dumps({'error': 'Photo ID required'})
            }

        # Get photo metadata from DynamoDB
        response = table.get_item(Key={'photoId': photo_id})

        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({'error': 'Photo not found'})
            }

        photo = response['Item']

        # Delete from S3
        if photo.get('s3Key'):
            try:
                s3.delete_object(Bucket=BUCKET_NAME, Key=photo['s3Key'])
            except:
                pass

        # Delete from DynamoDB
        table.delete_item(Key={'photoId': photo_id})

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Methods': 'DELETE, OPTIONS',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'message': 'Photo deleted successfully'})
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
