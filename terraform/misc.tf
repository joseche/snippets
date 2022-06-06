terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3"
    }
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]  # encripted
    # values = ["amzn2-ami-hvm*"]  - not encripted
  }
}

data "aws_region" "current" {}

resource "aws_instance" "someapp" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_groups
  iam_instance_profile   = var.instance_profile
  subnet_id              = var.instance_subnet_id
  tags = merge(var.additional_tags, {
    Name = "${var.resource_prefix}-someapp"
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = "500"
  }
}
