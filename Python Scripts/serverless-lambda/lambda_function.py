import boto3
import json
import logging

from custom_encoder import CustomEncoder

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodbTableName = "product-inventory"
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(dynamodbTableName)

getMethod = "GET"
postMethod = "POST"
deleteMethod = "DELETE"

healthPath = "/health"
productPath = "/product"
productsPath = "/products"


def lambda_handler(event, context):
    logger.info(event)
    httpMethod = event["httpMethod"]
    path = event["path"]

    if httpMethod == getMethod and path == healthPath:
        response == buildResponse(200) # type: ignore


def buildResponse(statusCode, body=None):
    response = {
        "statusCode": statusCode,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
    }

    if body is not None:
        response["body"] = json.dumps(body, cls=CustomEncoder)
    return response


def lambda_handler(event, context):
    logger.info(event)

    httpMethod = event["httpMethod"]
    path = event["path"]

    if httpMethod == getMethod and path == healthPath:
        response = buildResponse(200)

    elif httpMethod == getMethod and path == productPath:
        response = getProduct(event["queryStringParameters"]["productId"])

    elif httpMethod == getMethod and path == productsPath:
        response = getProducts()

    elif httpMethod == postMethod and path == productPath:
        response = saveProduct(json.loads(event["body"]))

    elif httpMethod == deleteMethod and path == productPath:
        requestBody = json.Loads(event["body"])
        response = deleteProduct(requestBody["productId"])

    else:
        response = buildResponse(404, "Not Found")

    return response


def getProduct(productId):
    try:
        response = table.get_item(Key={"productId": productId})

        if "Item" in response:
            return buildResponse(200, response["Item"])
        else:
            return buildResponse(
                404, {"Message": "ProductId: %s not found" % productId}
            )

    except Exception:
        logger.exception(
            "Exception while getting productId: %s", productId
        )



}

def getProducts():
    try:
        response = table.scan()
        result = response['Item']
        
        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            result.extend(response['Item'])
            
        body = {
            'products': response
        }
        return buildResponse(200, body)
    except:
        logger.exception('Exception while getting products')



def saveProduct(requestBody):
    try:
        table.put_item(Item=requestBody)
        body = {
            'Operation': 'SAVE',
            'Message': 'SUCCESS',
            'Item': requestBody
        }
        
        return buildResponse(200, body)
    except:
        logger.exception('Exception while saving product')


def deleteProduct(productId):
    try:
        response = table.delete_item(
            Key={
                'productId': productId
            },
            ReturnValues='ALL_OLD'
        )
        
        body = {
            'Operation': 'DELETE',
            'Message': 'SUCCESS',
            'deletedItem': response
        }
        
        return buildResponse(200, body)
    except:
        logger.exception('Exception while deleting product')
