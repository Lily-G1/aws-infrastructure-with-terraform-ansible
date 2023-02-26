# Inbound traffic rules
variable "ingress_rules" {
  default = [{
    port        = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }]
}

# Outbound traffic rules
variable "egress_rules" {
  default = [{
    port        = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

# VPC CIDR
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block"
}

# VPC name
variable "vpc_name" {
  type        = string
  default     = "project-vpc"
  description = "name of VPC"
}

# Subnet CIDR list
variable "subnet_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "subnet CIDR"
}

# Subnet availability zones
variable "az" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "availability zone"
}

# Type of EC2 instance
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

# ID of EC2 instance AMI
variable "ami" {
  type        = string
  default     = "ami-0778521d914d23bc1"
  description = "ID of Instance AMI"
}

# AWS keypair
variable "ssh_key_pair" {
  type        = string
  description = "name of AWS SSH key-pair"
}

# Load balancer details
variable "lb_type" {
  type    = string
  default = "application"
}

variable "lb_port" {
  type    = number
  default = 80
}

variable "lb_protocol" {
  type    = string
  default = "HTTP"
}

variable "lb_target_type" {
  type    = string
  default = "instance"
}


# Ansible playbook directory
variable "dir_path" {
  default     = "/home/vagrant/terraform-ansible-project"
  description = "ansible directory"
}

variable "file_permission" {
  type    = string
  default = "0664"
}


# Domain name
variable "domain" {
  type        = string
  default     = "liliangaladima.website"
  description = "domain name"
}

# Sub-domain name
variable "subdomain" {
  type        = string
  default     = "terraform-test.liliangaladima.website"
  description = "name of sub domain"
}