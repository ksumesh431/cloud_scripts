import aws_cdk as core
import aws_cdk.assertions as assertions

from serverless_api.serverless_api_stack import ServerlessApiStack

# example tests. To run these tests, uncomment this file along with the example
# resource in serverless_api/serverless_api_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = ServerlessApiStack(app, "serverless-api")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
