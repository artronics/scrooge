resource "aws_ecr_repository" "scrooge_repo" {
  name                 = local.prefix
  image_tag_mutability = "MUTABLE"
}

locals {
  scrooge_path = "${path.cwd}/../${local.project}"
  image_tag    = "${aws_ecr_repository.scrooge_repo.repository_url}:${var.tag}"
  build_dir    = abspath("${path.root}/build")
}

data "archive_file" "scrooge_source_archive" {
  type        = "zip"
  source_dir  = local.scrooge_path
  output_path = "${local.build_dir}/${local.project}_src.zip"
}

data "archive_file" "scrooge_bin_archive" {
  type        = "zip"
  source_file = "${local.build_dir}/${local.project}"
  output_path = "${local.build_dir}/${local.project}.zip"
  depends_on  = [null_resource.build_scrooge]
}

resource "null_resource" "build_scrooge" {
  triggers = {
    src_hash = data.archive_file.scrooge_source_archive.output_sha
  }
  provisioner "local-exec" {
    command = <<EOF
cd ${local.scrooge_path}
GO111MODULE=on GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o ${local.build_dir}/scrooge github.com/artronics/scrooge
EOF
  }
}

resource "null_resource" "scrooge_image_push" {
  triggers = {
    src_hash = data.archive_file.scrooge_source_archive.output_sha
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
