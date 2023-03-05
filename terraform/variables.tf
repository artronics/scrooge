variable "vpc_id" {
  default = "vpc-095f6abc714dbc0a5"
  description = "VPC id of the network where lambda residing. This will be used to connect EFS mount point to connect to lambda"
}

variable "tag" {
  description = "scrooge docker tag"
}
