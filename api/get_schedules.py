import boto3
from typing import Literal
from dataclasses import dataclass, asdict
from os import environ as env
from parser import Parser
import json
import jwt
from botocore.exceptions import ClientError

client = boto3.client('scheduler')


@dataclass(frozen=True)
class ScheduleResponseDto:
    name: str
    type: Literal['WEEKLY', 'DAILY', 'MONTHLY']
    time: str
    days: list[int]
    webhook_url: str
    content: str

    def response(self):
        return


def get_schedules(user_id):
    user_id = str(user_id)
    schedules = []

    try:
        schedules = client.list_schedules(
            GroupName=user_id,
            MaxResults=100
        )['Schedules']
    except ClientError as err:
        if err.response['Error']['Code'] == 'ResourceNotFoundException':
            print(
                f"No schedule group for user {user_id}. Creating new group...")
            client.create_schedule_group(Name=user_id)
        else:
            raise err

    ret = []
    for schedule in schedules:
        data = client.get_schedule(
            GroupName=user_id,
            Name=schedule['Name'])
        expr = data['ScheduleExpression']
        parsed = Parser.parse_expr(expr)
        inputs = json.loads(data['Target']['Input'])
        ret.append(
            ScheduleResponseDto(
                name=data['Name'],
                type=parsed['routine_type'],
                days=parsed['days'],
                time=parsed['time'],
                webhook_url=inputs['webhook_url'],
                content=inputs['content']
            )
        )
    return ret


# TODO: bundle as module
def get_user_id(token):
    return jwt.decode(token, env['JWT_PUBLIC_KEY'], algorithms=['RS256'])['sub']


def handler(event, context):
    if event['requestContext']['http']['method'] == 'OPTIONS':  # CORS Handling
        body = None
    else:
        token = event['headers']['authorization'].split()[1]
        user_id = get_user_id(token)
        body = json.dumps({
            'data': list(map(asdict, get_schedules(user_id)))
        })

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,PUT',
            'Access-Control-Allow-Origin': 'http://localhost:5173',
        },
        'body': body
    }
