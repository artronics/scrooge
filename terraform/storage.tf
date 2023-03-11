locals {
  // TODO: should come from infra platform az
  platform_subnet_az_1 = "eu-west-2a"
}
resource "aws_efs_file_system" "scrooge_storage" {
  creation_token         = local.prefix
  availability_zone_name = local.platform_subnet_az_1
  tags                   = {
    Name = local.prefix
  }
}

resource "aws_efs_access_point" "scrooge_efs_access_point" {
  file_system_id = aws_efs_file_system.scrooge_storage.id

  root_directory {
    path = "/${local.prefix}/projects"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "666"
    }
  }
  posix_user {
    uid            = 0
    gid            = 0
    secondary_gids = [1000]
  }

  tags = {
    Name = local.prefix
  }
}

resource "aws_efs_mount_target" "terraform_plugin_cache_mount" {
  file_system_id  = aws_efs_file_system.scrooge_storage.id
  subnet_id       = local.platform_subnet_ids[0]
  security_groups = [local.vpc_default_security_group]
}
