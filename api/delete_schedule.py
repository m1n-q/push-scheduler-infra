import boto3
from os import environ as env
import jwt
from urllib.parse import unquote

client = boto3.client('scheduler')


def delete_schedule(user_id, name):
    user_id = str(user_id)

    client.delete_schedule(
        GroupName=str(user_id),
        Name=name
    )


# TODO: bundle as module
def get_user_id(token):
    return jwt.decode(token, env['JWT_PUBLIC_KEY'], algorithms=['RS256'])['sub']


def handler(event, context):
    token = event['headers']['authorization'].split()[1]
    user_id = get_user_id(token)

    param = event['pathParameters']
    name = unquote(param['scheduleNameBase64'])
    delete_schedule(user_id, name)
    return {
        'statusCode': 204
    }
