output "codecommit_repository_clone_url_http" {
  value = aws_codecommit_repository.mycicd_repository.clone_url_http
}

output "codebuild_project_name" {
  value = aws_codebuild_project.myBuild.name
}

output "codepipeline_name" {
  value = aws_codepipeline.myPipeline.name
}
