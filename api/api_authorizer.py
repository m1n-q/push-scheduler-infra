import jwt
import json
from os import environ as env


def generate_policy(principalId, effect, resource):
    authResponse = {}
    authResponse['principalId'] = principalId
    if (effect and resource):
        policyDocument = {
            'Version': '2012-10-17',
            'Statement': [{
                'Action': 'execute-api:Invoke',
                'Effect': effect,
                'Resource': resource
            }]
        }
        authResponse['policyDocument'] = policyDocument
        authResponse['context'] = {
            'Access-Control-Allow-Origin': 'http://localhost:5173'
        }

    authResponse_JSON = json.dumps(authResponse)
    return authResponse_JSON


def extract_token(bearer_token):
    s = bearer_token.split(" ")
    if len(s) != 2 or s[0] != "Bearer":
        raise ValueError("Invalid Format")
    return s[1]


def validate(token):
    return jwt.decode(token, env['JWT_PUBLIC_KEY'], algorithms=['RS256'])


def handler(event, context):
    try:
        token = extract_token(event['authorizationToken'])
        validate(token)
        response = generate_policy('user', 'Allow', event['methodArn'])
    except Exception as e:
        raise Exception('Unauthorized')
    return json.loads(response)
