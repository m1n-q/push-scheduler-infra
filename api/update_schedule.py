import boto3
from typing import Literal, Optional
from dataclasses import dataclass
from parser import Parser
from os import environ as env
from urllib.parse import unquote
import json
import jwt

client = boto3.client('scheduler')


@dataclass
class UpdateScheduleRequestDto:
    type: Literal['WEEKLY', 'DAILY', 'MONTHLY']
    time: str
    days: list[int]  # should be empty list if type is DAILY
    webhook_url: str
    content: str


def update_schedule(user_id, name, dto: UpdateScheduleRequestDto):
    user_id = str(user_id)

    hour, minute = dto.time.split(':')
    data = client.get_schedule(GroupName=user_id, Name=name)
    target = data['Target']
    target['Input'] = json.dumps({
        'webhook_url': dto.webhook_url,
        'content': dto.content
    })

    client.update_schedule(
        GroupName=user_id,
        Name=name,
        ScheduleExpression=Parser.to_expr(dto.type, dto.days, hour, minute),
        ScheduleExpressionTimezone='Asia/Seoul',
        FlexibleTimeWindow=data['FlexibleTimeWindow'],
        Target=target
    )


def get_user_id(token):
    return jwt.decode(token, env['JWT_PUBLIC_KEY'], algorithms=['RS256'])['sub']


def handler(event, context):
    token = event['headers']['authorization'].split()[1]
    user_id = get_user_id(token)

    body = json.loads(event['body'])
    param = event['pathParameters']
    name = unquote(param['scheduleNameBase64'])

    print(f'Update schedule [{user_id}]{name}')
    update_schedule(user_id, name, UpdateScheduleRequestDto(**body))

    return {
        'statusCode': 200,
        'body': 'OK'
    }
