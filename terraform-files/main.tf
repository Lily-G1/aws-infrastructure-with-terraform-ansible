# CREATE 3 INSTANCES BEHIND AN APPLICATION LOAD BALANCER

# Create VPC
resource "aws_vpc" "project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# Create internet gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "vpc-igw"
  }
}


# Create public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.subnet_cidr)
  vpc_id                  = aws_vpc.project_vpc.id
  cidr_block              = var.subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.az[count.index]

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}


# Create public route table & configure internet access
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_igw.id
}


# Associate subnets with public route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


# Create new load balancer
resource "aws_lb" "load_bal" {
  name               = "load-bal"
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.lb_sg.id]
  subnets	     = aws_subnet.public_subnet.*.id
  ip_address_type    = "ipv4"
}


# Create EC2 instances
resource "aws_instance" "web_servers" {
  count                  = 3
  instance_type          = var.instance_type
  ami                    = var.ami
  key_name               = var.ssh_key_pair
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.public_subnet[1].id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}


# Create target group for load balancer
resource "aws_lb_target_group" "target_grp" {
  name        = "lb-target-grp"
  target_type = var.lb_target_type
  port        = var.lb_port
  protocol    = var.lb_protocol
  vpc_id      = aws_vpc.project_vpc.id
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 15
    matcher             = 200
    path                = "/"
    timeout             = 3
    unhealthy_threshold = 3
  }
}


# Attach EC2 targets to target group
resource "aws_lb_target_group_attachment" "target_attach" {
  count            = length(aws_instance.web_servers)
  target_group_arn = aws_lb_target_group.target_grp.arn
  target_id        = aws_instance.web_servers[count.index].id
  port             = var.lb_port
}


# Create listener for load balancer
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.load_bal.arn
  port              = var.lb_port
  protocol          = var.lb_protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_grp.arn
  }
}


# Copy EC2 instances IP addresses to ansible host-inventory
resource "local_file" "ip_addresses" {
  content         = join("\n", aws_instance.web_servers[*].public_ip)
  filename        = "${var.dir_path}/host-inventory"
  file_permission = var.file_permission
}


# Create hosted zone and subdomain for load balancer DNS name 
resource "aws_route53_zone" "my_zone" {
  name = var.domain
}

resource "aws_route53_record" "a_record" {
  zone_id = aws_route53_zone.my_zone.zone_id
  name    = var.subdomain
  type    = "A"

  alias {
    name                   = aws_lb.load_bal.dns_name
    zone_id                = aws_lb.load_bal.zone_id
    evaluate_target_health = true
  }
}