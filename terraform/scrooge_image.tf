resource "aws_ecr_repository" "scrooge_repo" {
  name                 = local.prefix
  image_tag_mutability = "MUTABLE"
}

locals {
  scrooge_path = "${path.cwd}/../${local.project}"
  image_tag    = "${aws_ecr_repository.scrooge_repo.repository_url}:${var.tag}"
}

data "archive_file" "scrooge_archive" {
  type        = "zip"
  source_dir  = local.scrooge_path
  output_path = "build/${local.project}.zip"
}

resource "null_resource" "scrooge_image_push" {
  triggers   = {
    src_hash = data.archive_file.scrooge_archive.output_sha
  }

  provisioner "local-exec" {
    command = <<EOF
docker build -t ${local.image_tag} ${local.scrooge_path}
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password ${data.aws_ecr_authorization_token.token.password} ${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-2.amazonaws.com
docker push ${local.image_tag}
       EOF
  }
}

data "aws_ecr_image" "scrooge_image" {
  depends_on      = [null_resource.scrooge_image_push]
  repository_name = aws_ecr_repository.scrooge_repo.name
  image_tag       = var.tag
}
