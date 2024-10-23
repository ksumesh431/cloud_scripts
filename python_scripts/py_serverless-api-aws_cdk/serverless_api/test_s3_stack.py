# from aws_cdk import (
#     Stack,
#     aws_s3 as _s3,
#     RemovalPolicy,
#     CfnOutput,
# )
# from constructs import Construct


# class testS3Stack(Stack):

#     def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
#         super().__init__(scope, construct_id, **kwargs)

#         # The code that defines your stack goes here
#         my_bucket = _s3.Bucket(
#             self,
#             "MyBucket",
#             bucket_name="unique-bucket-test-us-east-1",
#             removal_policy=RemovalPolicy.DESTROY,
#         )

#         # Showing the bucket name and arn in the output
#         CfnOutput(self, "bucekt_output_name", value=my_bucket.bucket_name)
#         CfnOutput(self, "bucekt_output_arn", value=my_bucket.bucket_arn)
