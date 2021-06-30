resource "aws_security_group" "servicenet" {
  name        = "${var.name_prefix}-servicesg-${random_string.suffix.result}"
  description = "Security group for traffic"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "servicenet"
  }
}

resource "aws_security_group_rule" "servicenetout80" {
  security_group_id = aws_security_group.servicenet.id
  type              = "egress"
  description       = "OUT TO WORLD - HTTP"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "servicenetout443" {
  security_group_id = aws_security_group.servicenet.id
  type              = "egress"
  description       = "OUT TO WORLD - HTTPS"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "servicenetoutself" {
  for_each          = toset(var.service_ports)
  security_group_id = aws_security_group.servicenet.id
  type              = "egress"
  description       = "OUT TO SELF - ${each.key}"
  from_port         = each.key
  to_port           = each.key
  protocol          = lower(var.service_protocol)
  cidr_blocks       = [var.servicenet]
}

resource "aws_security_group_rule" "servicenetinself" {
  for_each          = toset(var.service_ports)
  security_group_id = aws_security_group.servicenet.id
  type              = "ingress"
  description       = "IN TO SELF - ${each.key}"
  from_port         = each.key
  to_port           = each.key
  protocol          = lower(var.service_protocol)
  cidr_blocks       = concat([var.servicenet], var.service_clients)
}
