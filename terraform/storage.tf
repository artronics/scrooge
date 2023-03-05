resource "aws_efs_file_system" "lambda_storage" {
  creation_token = "${local.prefix}-lambda"
  availability_zone_name = "eu-west-2a"
}

resource "aws_efs_access_point" "lambda_storage_access_point" {
  file_system_id = aws_efs_file_system.lambda_storage.id

  root_directory {
    path = "/lambda-files"
    creation_info {
      owner_gid = 1001
      owner_uid = 1001
      permissions = "755"
    }
  }
  posix_user {
    uid = 1001
    gid = 1001
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "${local.prefix}_efs_sg"
  description = "${local.prefix} - Security group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
#    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_efs_mount_target" "mount_target_1a" {
#  file_system_id = aws_efs_file_system.lambda_storage.id
#  subnet_id      = var.subnet_1a
#  security_groups = [ var.efs_sg_id ]
#}
