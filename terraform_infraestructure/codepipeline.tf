resource "aws_codepipeline" "simple_web_app_pipeline" {
    name     = "simple-web-app-pipeline"
    role_arn = aws_iam_role.apps_codepipeline_role.arn
    tags = {
        Environment = var.env
    }

    artifact_store {
        location = var.artifacts_bucket_name
        type     = "S3"
    }

    stage {
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["SourceArtifact"]
            configuration = {
                FullRepositoryId = var.nodejs_project_repository_name
                BranchName   = var.nodejs_project_repository_branch
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }
    stage {
        name = "Build"

        action {
        category = "Build"
        configuration = {
            "EnvironmentVariables" = jsonencode(
            [
                {
                name  = "environment"
                type  = "PLAINTEXT"
                value = var.env
                },
                {
                name  = "AWS_DEFAULT_REGION"
                type  = "PLAINTEXT"
                value = var.aws_region
                },
                {
                name  = "AWS_ACCOUNT_ID"
                type  = "PARAMETER_STORE"
                value = "ACCOUNT_ID"
                },
                {
                name  = "IMAGE_REPO_NAME"
                type  = "PLAINTEXT"
                value = "simple-web-app"
                },
                {
                name  = "IMAGE_TAG"
                type  = "PLAINTEXT"
                value = "latest"
                },
                {
                name  = "CONTAINER_NAME"
                type  = "PLAINTEXT"
                value = var.container_name
                },
            ]
            )
            "ProjectName" = aws_codebuild_project.containerSimpleWebAppBuild.name
        }
        input_artifacts = [
            "SourceArtifact",
        ]
        name = "Build"
        output_artifacts = [
            "BuildArtifact",
        ]
        owner     = "AWS"
        provider  = "CodeBuild"
        run_order = 1
        version   = "1"
        }
    }
    stage {
        name = "Deploy"

        action {
        category = "Deploy"
        configuration = {
            "ClusterName" = module.ecs-cluster.aws_ecs_cluster_cluster_name
            "ServiceName" = module.ecs-fargate-service.aws_ecs_service_service_name
            "FileName"    = "imagedefinitions.json"
            #"DeploymentTimeout" = "15"
        }
        input_artifacts = [
            "BuildArtifact",
        ]
        name             = "Deploy"
        output_artifacts = []
        owner            = "AWS"
        provider         = "ECS"
        run_order        = 1
        version          = "1"
        }
    }
}
