import boto3
from typing import Literal
from dataclasses import dataclass
from parser import Parser
from os import environ as env
import json
import jwt

client = boto3.client('scheduler')


@dataclass
class CreateScheduleRequestDto:
    name: str
    type: Literal['WEEKLY', 'DAILY', 'MONTHLY']
    time: str
    days: list[int]  # should be empty list if type is DAILY
    webhook_url: str
    content: str


def create_schedule(user_id, data: CreateScheduleRequestDto):
    hour, minute = data.time.split(':')
    user_id = str(user_id)

    client.create_schedule(
        GroupName=str(user_id),
        Name=data.name,
        ScheduleExpression=Parser.to_expr(data.type, data.days, hour, minute),
        ScheduleExpressionTimezone='Asia/Seoul',
        FlexibleTimeWindow={'Mode': 'OFF'},
        Target={
            'Arn': env['WORKER_LAMBDA_ARN'],
            'RoleArn': env['WORKER_LAMBDA_ROLE_ARN'],
            'Input': json.dumps({
                'webhook_url': data.webhook_url,
                'content': data.content
            })
        },
    )

# TODO: bundle as module
def get_user_id(token):
    return jwt.decode(token, env['JWT_PUBLIC_KEY'], algorithms=['RS256'])['sub']


def handler(event, context):

    token = event['headers']['authorization'].split()[1]
    user_id = get_user_id(token)

    body = json.loads(event['body'])
    create_schedule(user_id, CreateScheduleRequestDto(**body))
    return {
        'statusCode': 200,
        'body': 'OK'
    }
