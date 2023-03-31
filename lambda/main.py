import json
import boto3
import time
import os

dynamo = boto3.resource('dynamodb')
table_name = os.environ['DB_NAME']
table = dynamo.Table(table_name)

def lambda_handler(event, context):
    ts = round(time.time())
    data = table.get_item(Key={
            'visitor_id': event['context']['source-ip']
    })
    if 'Item' not in data:
        data['Item'] = None
        
    res = table.get_item(Key={
        'visitor_id': '0'
    })
    
    if data['Item'] is None or data['Item']['timestamp'] < ts - 86400:
        table.put_item(Item={
            'visitor_id': event['context']['source-ip'],
            'timestamp': ts
        })
            
        res['Item']['count'] = res['Item']['count']+1
        res['Item']['timestamp'] = ts
        table.put_item(Item=res['Item'])

    return res['Item']['count']
   
    