import os
import boto3

client = boto3.client('dynamodb')
table = os.environ["TABLE_NAME"]

def update_hit():
    response = client.update_item(
        TableName=table,
        Key={'id': {'S': "1"}},
        ReturnValues='UPDATED_NEW',
        UpdateExpression='ADD hit_count :val',
        ExpressionAttributeValues={":val": {"N": "1"}}
    )
    return response["Attributes"]["hit_count"]["N"]

def handler(event, context):
    item = update_hit().zfill(5)
    result = {
        "statusCode": 200,
        "statusDescription": "200 OK",
        "isBase64Encoded": False,
        "headers": {"Content-Type": "text/json; charset=utf-8"},
        "body": item
        }
    return result