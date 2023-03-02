resource "aws_ecr_repository" "scrooge_repo" {
  name                 = local.prefix
  image_tag_mutability = "MUTABLE"
}

locals {
  scrooge_path = "${path.cwd}/../${local.project}"
}

data "archive_file" "scrooge_archive" {
  type        = "zip"
  source_dir  = local.scrooge_path
  output_path = "build/${local.project}.zip"
}

resource "docker_image" "scrooge_remote_build_image" {
  name = "${aws_ecr_repository.scrooge_repo.repository_url}:${var.tag}"
  build {
    context = local.scrooge_path
    tag     = ["scrooge:local"]
  }
}

resource "null_resource" "scrooge_image_push" {
  depends_on = [aws_ecr_repository.scrooge_repo, docker_image.scrooge_remote_build_image]
  triggers   = {
    src_hash = data.archive_file.scrooge_archive.output_sha
  }

  provisioner "local-exec" {
    command = <<EOF
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password ${data.aws_ecr_authorization_token.token.password} ${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com
docker push ${aws_ecr_repository.scrooge_repo.repository_url}:${var.tag}
       EOF
  }
}

data "aws_ecr_image" "mock-receiver_image" {
  depends_on      = [null_resource.scrooge_image_push]
  repository_name = aws_ecr_repository.scrooge_repo.name
  image_tag       = var.tag
}
