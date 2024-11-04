# README for Product Inventory Management Lambda Function

## Overview

This project implements an AWS Lambda function for managing a product inventory stored in an Amazon DynamoDB table. The function supports various HTTP methods (GET, POST, DELETE) to interact with the product inventory. It is designed to be used in a serverless architecture, allowing easy integration with API Gateway for HTTP requests.

## Features

- **Health Check**: Responds to health check requests to verify the service's availability.
- **Product Retrieval**: Fetches details of a specific product or all products from the inventory.
- **Product Storage**: Saves a new product to the inventory.
- **Product Deletion**: Deletes a product from the inventory using its product ID.

## Architecture

The Lambda function is structured to handle different HTTP methods and paths, making it flexible for RESTful API interactions. It uses the following AWS services:

- **AWS Lambda**: For executing the serverless function.
- **Amazon DynamoDB**: For storing product inventory.

## Prerequisites

- **AWS Account**: You need an AWS account to deploy the Lambda function and create a DynamoDB table.
- **AWS CLI**: To manage AWS services and deploy the Lambda function.
- **Python 3.6 or later**: The function is written in Python.

## Setup

1. **Create a DynamoDB Table**:
   - Name: `product-inventory`
   - Primary Key: `productId` (String)

2. **Clone this Repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

3. **Install Required Packages**:

   Install the necessary packages using pip:

   ```bash
   pip install boto3
   ```

## Custom Encoder

### CustomEncoder Class

The `CustomEncoder` class is defined to handle the serialization of `Decimal` objects in JSON. In AWS, when retrieving numerical values from DynamoDB, they are often represented as `Decimal` types, which are not natively serializable to JSON. 

```python
import json
from decimal import Decimal

class CustomEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)  # Convert Decimal to float for JSON serialization
        return json.JSONEncoder.default(self, obj)
```

#### Significance

- **Serialization**: The `CustomEncoder` ensures that all data types returned from DynamoDB can be correctly serialized into JSON format, specifically converting `Decimal` types into `float`.
- **Error Prevention**: Without this encoder, attempting to serialize a `Decimal` type would raise a `TypeError`, preventing the successful return of data from the Lambda function.

## Lambda Function Implementation

### Code Structure

The main Lambda function file handles the incoming events, processes HTTP methods, and interacts with the DynamoDB table. The key functions include:

- **`lambda_handler(event, context)`**: The entry point of the Lambda function.
- **`buildResponse(statusCode, body=None)`**: Constructs a consistent HTTP response structure.
- **`getProduct(productId)`**: Retrieves a product by its ID.
- **`getProducts()`**: Retrieves all products from the inventory.
- **`saveProduct(requestBody)`**: Saves a new product to the inventory.
- **`deleteProduct(productId)`**: Deletes a product from the inventory by its ID.

### Example Usage

1. **Health Check**: 
   - **Endpoint**: `GET /health`
   - **Response**: HTTP 200 OK

2. **Get Product**:
   - **Endpoint**: `GET /product?productId=<id>`
   - **Response**: HTTP 200 with product details or 404 if not found.

3. **Get All Products**:
   - **Endpoint**: `GET /products`
   - **Response**: HTTP 200 with a list of products.

4. **Save Product**:
   - **Endpoint**: `POST /product`
   - **Request Body**: JSON object representing the product.
   - **Response**: HTTP 200 on success.

5. **Delete Product**:
   - **Endpoint**: `DELETE /product`
   - **Request Body**: JSON object with `productId`.
   - **Response**: HTTP 200 on success.

## Deployment

To deploy the Lambda function:

1. Zip the contents of your project directory.
2. Use the AWS CLI to deploy the function.

```bash
aws lambda create-function --function-name ProductInventoryFunction --zip-file fileb://function.zip --handler <handler-file>.lambda_handler --runtime python3.8 --role <role-arn>
```

Replace `<handler-file>` with the name of your Python file without the `.py` extension and `<role-arn>` with the ARN of the IAM role with appropriate permissions.

## Logging

The script uses Python’s logging library to log events. You can monitor the logs using AWS CloudWatch to troubleshoot issues or to monitor function execution.

## Conclusion

This Lambda function serves as a robust solution for managing product inventory in a serverless architecture. It can be easily extended or modified to add more functionality as needed.