resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.name_prefix}-vpc-${random_string.suffix.result}"
  }
}

resource "aws_vpc_dhcp_options" "dhcp-opts" {
  domain_name         = "${var.name_prefix}${random_string.suffix.result}.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "dhcp-assoc" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp-opts.id
}

resource "aws_subnet" "gatewaynet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = var.gatewaynet
  tags = {
    Name = "${var.name_prefix}-gatewaynet-${random_string.suffix.result}"
  }
}

resource "aws_subnet" "servicenet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[0]
  cidr_block        = var.servicenet
  tags = {
    Name = "${var.name_prefix}-servicenet-${random_string.suffix.result}"
  }
}

resource "aws_eip" "ng-eip" {
  vpc = true
  tags = {
    Name = "${var.name_prefix}-ng-eip-${random_string.suffix.result}"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.name_prefix}-ig-${random_string.suffix.result}"
  }
}

resource "aws_nat_gateway" "ng" {
  allocation_id = aws_eip.ng-eip.id
  subnet_id     = aws_subnet.gatewaynet.id
  tags = {
    Name = "${var.name_prefix}-ng-${random_string.suffix.result}"
  }
  depends_on = [aws_internet_gateway.ig]
}

resource "aws_route_table" "gatewaynet" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }
  tags = {
    Name = "${var.name_prefix}-gatewayrt-${random_string.suffix.result}"
  }
}

resource "aws_route_table" "servicenet" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ng.id
  }
  tags = {
    Name = "${var.name_prefix}-servicert-${random_string.suffix.result}"
  }
}

resource "aws_route_table_association" "gatewaynet" {
  subnet_id      = aws_subnet.gatewaynet.id
  route_table_id = aws_route_table.gatewaynet.id
}

resource "aws_route_table_association" "servicenet" {
  subnet_id      = aws_subnet.servicenet.id
  route_table_id = aws_route_table.servicenet.id
}
