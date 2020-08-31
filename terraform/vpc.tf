# VPC Resources
#  * VPC
#  * Subnets

resource "aws_vpc" "ctest" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = map(
    "Name", "terraform-eks-ctest-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "ctest" {
  count = 3

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
#  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.ctest.id

  tags = map(
    "Name", "terraform-eks-ctest-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

# EC2 VPC Endpoint security groups
resource "aws_security_group" "endpoint_ec2" {
  name   = "endpoint-ec2-sg"
  vpc_id = aws_vpc.ctest.id
}

resource "aws_security_group_rule" "endpoint_ec2_443" {
  security_group_id = aws_security_group.endpoint_ec2.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
}

# EC2 VPC Endpoint
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.ctest.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.ctest[*].id
  security_group_ids  = [aws_security_group.endpoint_ec2.id]

  tags = {
    Name = "EC2 VPC Endpoint Interface"
  }
}
