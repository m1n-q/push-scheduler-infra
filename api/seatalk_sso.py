import datetime
from os import environ as env
import json
import http.client as http
import jwt

conn = http.HTTPSConnection('openapi.seatalk.io')


def get_app_access_token():
    """
        API is limited to 600 requests per hour. NEED TO BE CACHED
    """
    id, secret = env['SEATALK_APP_ID'], env['SEATALK_APP_SECRET']
    headers = {
        'Content-Type': 'application/json'
    }
    body = json.dumps({
        "app_id": id,
        "app_secret": secret
    })

    conn.request('POST', '/auth/app_access_token', body, headers)
    response = json.loads(conn.getresponse().read().decode())
    return response['app_access_token']


def code2employee(app_access_token, authorization_code):
    headers = {
        'Authorization': f'Bearer {app_access_token}'
    }
    conn.request('GET', f'/open_login/code2employee?code={authorization_code}',
                 headers=headers)
    r = conn.getresponse().read()
    print(f"---with code {authorization_code}---")
    print(r)
    response = json.loads(r.decode())

    return response['employee']


def issue_jwt(authorization_code):
    employee = code2employee(get_app_access_token(), authorization_code)
    iat = datetime.datetime.now(datetime.UTC)
    exp = iat + datetime.timedelta(seconds=7200)
    payload = {
        "sub": employee['employee_code'],
        "iss": "seatalk-push-manager",
        "iat": iat,
        "exp": exp,
        "name": employee['name'],
        "avatar": employee['avatar'],
    }

    token = jwt.encode(
        payload=payload,
        algorithm='RS256',
        key=env['JWT_PRIVATE_KEY'],

    )
    return token


def handler(event, context):
    body = json.loads(event['body'])
    token = issue_jwt(body['code'])
    return {
        'statusCode': 200,
        'body': token
    }