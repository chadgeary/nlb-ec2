data "aws_ami" "latest" {
  most_recent = true
  owners      = [var.vendor_ami_account_number]
  filter {
    name   = "name"
    values = [var.vendor_ami_name_string]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["arm64", "x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.name_prefix}-ssh-${random_string.suffix.result}"
  public_key = var.ssh_key
  tags = {
    Name = "${var.name_prefix}-ssh-${random_string.suffix.result}"
  }
}

data "aws_iam_policy" "instance1" {
  arn = "arn:${data.aws_partition.aws-partition.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "instance1" {
  name               = "${var.name_prefix}-instance-role-${random_string.suffix.result}"
  path               = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "instance1" {
  role       = aws_iam_role.instance1.name
  policy_arn = data.aws_iam_policy.instance1.arn
}

resource "aws_iam_instance_profile" "instance1" {
  name = "${var.name_prefix}-instance1-${random_string.suffix.result}"
  role = aws_iam_role.instance1.name
}

resource "aws_instance" "instance1" {
  ami                    = data.aws_ami.latest.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ssh.key_name
  vpc_security_group_ids = [aws_security_group.servicenet.id]
  subnet_id              = aws_subnet.servicenet.id
  private_ip             = var.instanceA
  root_block_device {
    volume_size = var.instance_diskgb
    volume_type = "standard"
    encrypted   = "true"
  }
  iam_instance_profile = aws_iam_instance_profile.instance1.name
  user_data            = <<EOF
#!/bin/bash
echo "hello world!"
EOF
}
