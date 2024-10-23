from aws_cdk import (
    Stack,
    aws_iam as iam,
    aws_apigateway as apigateway,
    aws_lambda as lambda_,
    aws_dynamodb as dynamodb,
    RemovalPolicy,
    CfnOutput,
)
from constructs import Construct

class ServerlessApiStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Create IAM role with permissions to access DynamoDB and CloudWatch
        role = iam.Role(
            self,
            "LambdaExecutionRole",
            assumed_by=iam.ServicePrincipal("lambda.amazonaws.com"),
            managed_policies=[
                iam.ManagedPolicy.from_aws_managed_policy_name(
                    "AmazonDynamoDBFullAccess"
                ),
                iam.ManagedPolicy.from_aws_managed_policy_name(
                    "CloudWatchFullAccessV2"
                ),
            ],
        )

        # Create Lambda function
        lambda_function = lambda_.Function(
            self,
            "ProductInventoryFunction",
            runtime=lambda_.Runtime.PYTHON_3_9,
            code=lambda_.Code.from_asset("lambda"),
            handler="index.lambda_handler",
            role=role,
        )

        # Create API Gateway REST API
        api = apigateway.RestApi(self, "ProductInventoryAPI")

        # Define API Gateway resources and methods
        health_resource = api.root.add_resource("health")
        products_resource = api.root.add_resource("products")
        product_resource = api.root.add_resource("product")

        health_resource.add_method("GET", apigateway.LambdaIntegration(lambda_function))
        products_resource.add_method(
            "GET", apigateway.LambdaIntegration(lambda_function)
        )
        product_resource.add_method(
            "POST", apigateway.LambdaIntegration(lambda_function)
        )

        # Create DynamoDB table to store product inventory
        product_inventory_table = dynamodb.Table(
            self,
            "ProductInventoryTable",
            partition_key=dynamodb.Attribute(
                name="productId", type=dynamodb.AttributeType.STRING
            ),
            table_name="product-inventory",
            billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST,
            removal_policy=RemovalPolicy.DESTROY,
        )

        # Output values
        apigateway_output = CfnOutput(self, "APIUrl", value=api.url)
        lambda_output = CfnOutput(self, "LambdaARN", value=lambda_function.function_arn)
        dynamodb_output = CfnOutput(
            self, "DynamoDBTable", value=product_inventory_table.table_name
        )
