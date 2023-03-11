resource "aws_vpc_endpoint" "s3" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_vpc_endpoint_rt.id]

  tags = {
    Name = "${local.prefix}-s3"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.platform_subnet_ids
  security_group_ids  = [local.vpc_default_security_group]

  tags = {
    Name = "${local.prefix}-cloudwatch"
  }
}

resource "aws_route_table" "private_vpc_endpoint_rt" {
  vpc_id = local.vpc_id

  tags = {
    Name = local.prefix
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_vpc_endpoint_route_table" {
  route_table_id  = aws_route_table.private_vpc_endpoint_rt.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_route_table_association" "private_route_table_assoc" {
  count = length(local.platform_subnet_ids)

  route_table_id = aws_route_table.private_vpc_endpoint_rt.id
  subnet_id      = local.platform_subnet_ids[count.index]
}
