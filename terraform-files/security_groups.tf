# Security group for load balancer
resource "aws_security_group" "lb_sg" {
  name        = "loadbal-sec-grp"
  description = "allow inbound TLS traffic"
  vpc_id = aws_vpc.project_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules

    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}


# Security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sec-grp"
  description = "allow inbound TLS & SSH traffic"
  vpc_id = aws_vpc.project_vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port   = 22
      to_port     = 22
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      protocol        = ingress.value.protocol
      security_groups = [aws_security_group.lb_sg.id]
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules

    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}