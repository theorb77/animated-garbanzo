import boto3 
import os
import sys
from flask import Flask
from opentelemetry.instrumentation.flask import FlaskInstrumentor

app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)
dynamodb = boto3.resource('dynamodb', 
           region_name=os.environ['AWS_REGION'], 
           aws_access_key_id=os.environ['ACCESS_ID'], 
           aws_secret_access_key=os.environ['ACCESS_KEY'])
table = dynamodb.Table("simpletable")
result = table.scan()
if result is not None:
    item = result['Items'][0]['simplekey']
else:
    raise Exception("Couldn't retrieve 'Hello World'")

@app.route('/')
def hello_world():
    response = "Hello World"
 #   if item is not None:
 #       response = item
 #   else:
 #       response = '500 (Internal Server Error)'
    return response

@app.route('/health')
def health_check():
    response = "200 (OK)"
    return response

if __name__ == "__main__":
    app.run(debug=True)
