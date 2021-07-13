#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-eks-demo-node"
    Owner = "pei.b.liu"
    Environment = "dev"
  }
}

locals {
  subnet_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_subnet" "demo" {
  count = 2

  availability_zone       = local.subnet_availability_zones[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.demo.id
  map_public_ip_on_launch = "true"

  tags = {
    Name = "terraform-eks-demo-node"
    Owner = "pei.b.liu"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

resource "aws_route_table_association" "demo" {
  count = 2
  subnet_id      = aws_subnet.demo.*.id[count.index]
  route_table_id = aws_route_table.demo.id
}
