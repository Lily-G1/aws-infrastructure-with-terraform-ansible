# aws-infrastructure-with-terraform-ansible  
## Build an AWS environment using terraform and ansible  

Details:  
This directory contains two sub-folders: a terraform directory containing .tf files and an ansible directory. They work together to create 3 EC2 instances 
sitted behind an application load balancer. The instances have Apache installed and display current time/date and their respective host-names on their respective web pages    

terraform-files:  

main.tf: main configuration for infrastructure  
variables.tf: declares all variables used  
security_groups.tf: defines security rules  
outputs.tf: defines required output values  
provider.tf: declares AWS provider details & credentials for access  

ansibles-files:  

ansible.cfg: configuration file  
host-inventory: contains list of hosts IP addresses generated & imported from terraform configuration above  
install_apache.yml: playbook to simultaneously install Apache web server on instances created by terraform

