output "output" {
  value = <<OUTPUT
NAT IP: ${aws_eip.ng-eip.public_ip}
DNS: ${aws_lb.nlb.dns_name}
InstanceA: ${aws_instance.instance1.id}
OUTPUT
}
