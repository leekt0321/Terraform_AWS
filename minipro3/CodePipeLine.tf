# 프로바이더 설정
provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_codecommit_repository" "mycicd_repository" {
  repository_name = "cicd-project-repo"
  description = "CodeCommit repository for CICD project"
  default_branch = "main"
}

# codebuild를 위한 IAM 역할 생성
resource "aws_iam_role" "codebuild_role" {
  name = "cicd-project-codebuild-role"

  assume_role_policy = jsonencode({   # 신뢰정책 정의: 역할을 맡을 수 있는 주체와 조건을 정의
    Version = "2012-10-17"            # IAM 역할에 대한 특정 리소스 기반 정책 유형이다.
    Statement = [
      {
        Action = "sts:AssumeRole"   # 작업 허용
        Principal = {                # 가정(assume)할 역할 주체 정의
          Service = "codebuild.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""             # statement 식별자(디버깅, 정책을 읽거나 관리할때 유용)
      },
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_role_policy" {
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "codebuild:*",
          "s3:*"
        ],
        Resource = "*"
      }
    ]
  })
}

# CodeBuild Project 생성
resource "aws_codebuild_project" "myBuild" {
  name          = "cicd-project-build"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = "5"

  artifacts {         # 빌드 결과물 저장 방법 정의
    #type = "NO_ARTIFACTS" # 'NO_ARTIFACTS', 'S3', 'CODEPIPELINE'
    type     = "S3"
    location = aws_s3_bucket.myArtifacts.bucket
    packaging = "ZIP"
    name     = "codebuild-artifact.zip"
  }

  environment {       # 빌드 실행 환경 정의
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"   # codebuild를 실행할 도커이미지 지정
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"                    # 도커 이미지를 가져오는데 사용할 인증 정보 유형 지정(default: CODEBUILD/ SERVICE_ROLE: 사용자 지정 서비스 역할 사용)
  }

  source {            # 빌드할 소스 코드의 위치 및 유형 정의
    type      = "CODECOMMIT"   # 소스 코드 유형 지정
    location  = aws_codecommit_repository.mycicd_repository.clone_url_http # 소스코드 위치 지정
    buildspec = "buildspec.yml"  # 빌드할때 실행할 명령 파일 지정
    git_clone_depth = 1
  }
}

###############################################################
# codedeploy 역할
resource "aws_iam_role" "code_deploy_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codedeploy.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "code_deploy_role_policy" {
  role = aws_iam_role.code_deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectVersionAcl",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectVersionAcl"
        ],
        Resource = [
          "arn:aws:s3:::cicd-project-artifacts",
          "arn:aws:s3:::cicd-project-artifacts/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "tag:Get*",
          "tag:List*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "codedeploy:*",
          "s3:*",
          "cloudwatch:*",
          "sns:*",
          "autoscaling:*",
          "ec2:*",
          "lambda:*",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_codedeploy_app" "myEC2App" {
  compute_platform = "Server"
  name             = "cicd-project-ec2-app"
}

resource "aws_codedeploy_deployment_group" "myEC2DeploymentGroup" {
  app_name              = aws_codedeploy_app.myEC2App.name
  deployment_group_name = "cicd-project-ec2-deployment-group"
  service_role_arn      = aws_iam_role.code_deploy_role.arn

  
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "MyInstance"
    }

deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }


}
# 인스턴스와 AWS 서비스와의 상호작용 권한 설정
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}
resource "aws_iam_role_policy" "ec2_role_policy" {
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "codedeploy:*",
          "ec2:Describe*"
        ],
        Resource = [
          "arn:aws:s3:::aws-codedeploy-ap-northeast-2/latest/*",
          "arn:aws:s3:::aws-codedeploy-ap-northeast-2",
          "arn:aws:s3:::cicd-project-artifacts/*",
          "arn:aws:s3:::cicd-project-artifacts"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
# 인스턴스에 할당하기(인스턴스 프로파일: IAM 역할을 인스턴스에 부여)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}


# codepipeline을 위한 IAM 역할 생성
resource "aws_iam_role" "codepipeline_role" {
  name = "cicd-project-codepipeline-role"

  assume_role_policy = jsonencode({   # 신뢰정책 정의: 역할을 맡을 수 있는 주체와 조건을 정의
    Version = "2012-10-17"            # IAM 역할에 대한 특정 리소스 기반 정책 유형이다.
    Statement = [
      {
        Action = "sts:AssumeRole"   # 작업 허용
        Principal = {                # 가정(assume)할 역할 주체 정의
          Service = "codepipeline.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""             # statement 식별자(디버깅, 정책을 읽거나 관리할때 유용)
      },
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_role_policy" {
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "codebuild:*",
          "codecommit:*",
          "codedeploy:*",
          "cloudwatch:*",
          "iam:PassRole",
          "ec2:*",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# CodePipeline
resource "aws_codepipeline" "myPipeline" {
  name     = "cicd-project-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  

  artifact_store {        # 생성된 결과물 저장 위치 지정
    type     = "S3"
    location = aws_s3_bucket.myArtifacts.bucket
  }

  stage {             # 작업 실행 단계 정의
    name = "Source"     # 단계 이름 정의
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]   # 이 작업에서 생성할 출력 아티팩트 지정(파이프라인 내에서 고유해야 한다.)
      configuration = {
        RepositoryName = aws_codecommit_repository.mycicd_repository.repository_name
        BranchName = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]   # 이 작업에서 사용할 입력 아티팩트 지정
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {                      # 각 작업의 실행에 필요한 설정 값 지정(키-값 쌍의 사전 형식.)
        ProjectName = aws_codebuild_project.myBuild.name
      # codebuild의 configuration 옵션(참고:https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference.html)
      # ProjectName: my-build-project - 빌드를 수행할 codebuild 프로젝트의 이름 지정(필수)
      # BatchEnabled: 'true' - 여러 빌드를 한 번의 빌드 실행으로 수행 여부 (옵션)
      # CombineArtifacts: 'true' - 배치 빌드에서 모든 빌드 아티팩트를 하나의 아티팩트 파일로 결합 (옵션) -> 사용 시 BatchEnabled 활성화 필요
      # PrimarySource: MyApplicationSource1 - 여러 입력 아티팩트를 사용하는경우 빌드 사양 파일이 위치한 기본 소스 지정(옵션)
      # EnvironmentVariables: '[{"name":"TEST_VARIABLE","value":"TEST_VALUE","type":"PLAINTEXT"},{"name":"ParamStoreTest","value":"PARAMETER_NAME","type":"PARAMETER_STORE"}]'
      # |- 빌드 환경 변수의 키-값 쌍을 JSON 배열 형식으로 지정
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"
      configuration = {
        ApplicationName     = aws_codedeploy_app.myEC2App.name
        DeploymentGroupName = aws_codedeploy_deployment_group.myEC2DeploymentGroup.deployment_group_name
      }
    }
  }
}

# S3 Bucket for artifacts
resource "aws_s3_bucket" "myArtifacts" {
  bucket = "cicd-project-artifacts"
  force_destroy = true
  tags = {
    Name = "myArtifacts"
  }
}

resource "aws_s3_bucket_policy" "myArtifactsPolicy" {
  bucket = aws_s3_bucket.myArtifacts.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCodePipeline",
        Effect    = "Allow",
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action    = "s3:*",
        Resource  = [
          "${aws_s3_bucket.myArtifacts.arn}",
          "${aws_s3_bucket.myArtifacts.arn}/*"
        ]
      }
    ]
  })
}
