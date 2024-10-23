from aws_cdk import (
    Stack,
    aws_iam as iam,
    SecretValue,
    aws_codebuild as codebuild,
    aws_codecommit as codecommit,
    aws_codedeploy as codedeploy,
    aws_codepipeline as pipeline,
    aws_codepipeline_actions as pipelineactions,
    aws_elasticloadbalancingv2 as elb,
    aws_s3 as s3_,
    RemovalPolicy,
    CfnOutput,
)
from constructs import Construct


class PipelineStackFromScratch(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # Bucket with website static files
        static_files_hosting_bucket = s3_.Bucket(
            self,
            "static_files_hosting_bucket",
            bucket_name="static-files-hosting-bucket-from-cdk-unique965",
            auto_delete_objects=True,
            removal_policy=RemovalPolicy.DESTROY,
            public_read_access=True,
            block_public_access=s3_.BlockPublicAccess(
                block_public_policy=False,
            ),
            server_access_logs_prefix="server-access-logs",
            website_index_document="index.html",
        )
        static_files_hosting_bucket.add_cors_rule(
            allowed_methods=[s3_.HttpMethods.GET],
            allowed_origins=["*"],
            exposed_headers=[],  # No headers exposed in this case
            max_age=3600,  # Cache preflight response for 1 hour
        )

        # Code pipeline artifacts bcuket
        pipeline_artifacts_bucket = s3_.Bucket(
            self,
            "pipeline_artifacts_bucket",
            bucket_name="pipeline-artifacts-bucket-from-cdk-unique965",
            auto_delete_objects=True,
            removal_policy=RemovalPolicy.DESTROY,
        )

        source_artifact = pipeline.Artifact(artifact_name="SourceArtifact")

        build_artifact = pipeline.Artifact(artifact_name="BuildArtifact")

        # CodeBuild project that builds the static files from react
        build_image = codebuild.Project(
            self,
            "BuildImage",
            environment=codebuild.BuildEnvironment(
                build_image=codebuild.LinuxBuildImage.AMAZON_LINUX_2_5,
                compute_type=codebuild.ComputeType.MEDIUM,
            ),
            build_spec=codebuild.BuildSpec.from_source_filename("buildspec.yml"),
            source=codebuild.Source.git_hub(
                owner="ksumesh431",
                repo="react-deploy-test",
            ),
        )

        # Creates the source stage (Github) for CodePipeline
        source_stage = pipeline.StageProps(
            stage_name="Source",
            actions=[
                pipelineactions.GitHubSourceAction(
                    action_name="GitHubSource",
                    branch="main",
                    output=source_artifact,
                    repo="react-deploy-test",
                    oauth_token=SecretValue.secrets_manager(
                        "github_oauth_secret_json", json_field="oauth_key"
                    ),
                    owner="ksumesh431",
                )
            ],
        )

        # Creates the build stage for CodePipeline
        build_stage = pipeline.StageProps(
            stage_name="Build",
            actions=[
                pipelineactions.CodeBuildAction(
                    action_name="CodeBuild",
                    input=source_artifact,
                    project=build_image,
                    outputs=[build_artifact],
                )
            ],
        )

        # Creates the deploy stage for CodePipeline
        deploy_stage = pipeline.StageProps(
            stage_name="Deploy",
            actions=[
                pipelineactions.S3DeployAction(
                    action_name="DeployAction",
                    extract=True,
                    input=build_artifact,
                    bucket=static_files_hosting_bucket,
                )
            ],
        )

        # Creates an AWS CodePipeline with source, build, and deploy stages
        pipeline.Pipeline(
            self,
            "BuildDeployPipeline",
            artifact_bucket=pipeline_artifacts_bucket,
            pipeline_type=pipeline.PipelineType.V2,
            pipeline_name="ImageBuildDeployPipeline",
            stages=[source_stage, build_stage, deploy_stage],
        )
