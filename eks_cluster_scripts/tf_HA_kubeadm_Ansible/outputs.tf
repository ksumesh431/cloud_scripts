# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.kubeadm_vpc.id
}

# Output the CIDR block of the VPC
output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.kubeadm_vpc.cidr_block
}



output "ec2_ami_id" {
  description = "The AMI ID of the of the EC2 instance"
  value       = data.aws_ami.ubuntu.id
}

output "master1_private_ip" {
  description = "The private IP of the master1 instance"
  value       = aws_instance.master1.private_ip
}

output "master2_private_ip" {
  description = "The private IP of the master2 instance"
  value       = aws_instance.master2.private_ip
}

# output "master3_private_ip" {
#   description = "The private IP of the master3 instance"
#   value       = aws_instance.master3.private_ip
# }

# output "master4_private_ip" {
#   description = "The private IP of the master4 instance"
#   value       = aws_instance.master4.private_ip
# }

output "worker1_private_ip" {
  description = "The private IP of the worker1 instance"
  value       = aws_instance.worker1.private_ip
}

output "bastion_public_ip" {
  description = "The public IP of the bastion instance"
  value       = aws_instance.bastion.public_ip
}

output "api_server_nlb_dns" {
  description = "The DNS name of the network load balancer"
  value       = aws_lb.api_server_nlb.dns_name
}
