# IP addresses of EC2 instances
output "servers_ip_address" {
  value       = aws_instance.web_servers.*.public_ip
  description = "ip addresses of ec2 instances"
}


# NS records
output "name_servers" {
  value       = aws_route53_zone.my_zone.name_servers
  description = "records of domain name servers"
}