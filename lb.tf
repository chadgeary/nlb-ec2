resource "aws_lb" "nlb" {
  name                             = "${var.name_prefix}-node-nlb-${random_string.suffix.result}"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = "true"
  subnet_mapping {
    subnet_id            = aws_subnet.servicenet.id
    private_ipv4_address = var.nlbA
  }
  tags = {
    Name = "${var.name_prefix}-nlb-${random_string.suffix.result}"
  }
}

resource "aws_lb_target_group" "nlb" {
  count                = length(var.service_ports)
  port                 = var.service_ports[count.index]
  name                 = "${var.name_prefix}-${var.service_ports[count.index]}-${random_string.suffix.result}"
  protocol             = var.service_protocol
  vpc_id               = aws_vpc.vpc.id
  preserve_client_ip   = "true"
  deregistration_delay = 10
  target_type          = "instance"
  health_check {
    enabled             = "true"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    protocol            = "TCP"
  }
}

resource "aws_lb_listener" "nlb" {
  count             = length(var.service_ports)
  port              = var.service_ports[count.index]
  protocol          = var.service_protocol
  load_balancer_arn = aws_lb.nlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb[count.index].arn
  }
}

resource "aws_lb_target_group_attachment" "nlb" {
  count            = length(var.service_ports)
  target_group_arn = aws_lb_target_group.nlb[count.index].arn
  target_id        = aws_instance.instance1.id
  port             = count.index
}
