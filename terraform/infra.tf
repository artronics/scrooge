data "terraform_remote_state" "vajeh-infra" {
  backend = "s3"
  config  = {
    bucket = "vajeh-infra-ptl-terraform-state"
    key    = "state"
    region = "eu-west-2"
  }
}

locals {
  vpc_id                                  = data.terraform_remote_state.vajeh-infra.outputs.vpc_id
  platform_subnet_ids                     = data.terraform_remote_state.vajeh-infra.outputs.platform_subnet_ids
  vpc_default_security_group              = data.terraform_remote_state.vajeh-infra.outputs.vpc_default_security_group
  platform_efs_id                         = data.terraform_remote_state.vajeh-infra.outputs.platform_efs_id
  terraform_plugin_cache_efs_access_point = data.terraform_remote_state.vajeh-infra.outputs.terraform_plugin_cache_efs_access_point
}
