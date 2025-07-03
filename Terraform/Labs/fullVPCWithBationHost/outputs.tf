# # VPC Outputs
# output "vpc_id" {
#   description = "The ID of the VPC"
#   value       = aws_vpc.hawil_vpc.id
# }

# output "vpc_cidr_block" {
#   description = "The CIDR block of the VPC"
#   value       = aws_vpc.hawil_vpc.cidr_block
# }

# # Subnet Outputs
# output "public_subnet_id" {
#   description = "The ID of the public subnet"
#   value       = aws_subnet.hawil_public_subnet.id
# }

# output "public_subnet_cidr" {
#   description = "The CIDR block of the public subnet"
#   value       = aws_subnet.hawil_public_subnet.cidr_block
# }

# output "private_subnet_id" {
#   description = "The ID of the private subnet"
#   value       = aws_subnet.hawil_private_subnet.id
# }

# output "private_subnet_cidr" {
#   description = "The CIDR block of the private subnet"
#   value       = aws_subnet.hawil_private_subnet.cidr_block
# }

# # Gateway Outputs
# output "internet_gateway_id" {
#   description = "The ID of the Internet Gateway"
#   value       = aws_internet_gateway.hawil_internet_gateway.id
# }

# output "nat_gateway_id" {
#   description = "The ID of the NAT Gateway"
#   value       = aws_nat_gateway.hawil_nat_gateway.id
# }

# output "nat_gateway_public_ip" {
#   description = "The public IP address of the NAT Gateway"
#   value       = aws_eip.hawil_nat_eip.public_ip
# }

# # Route Table Outputs
# output "public_route_table_id" {
#   description = "The ID of the public route table"
#   value       = aws_route_table.hawil_public_route_table.id
# }

# output "private_route_table_id" {
#   description = "The ID of the private route table"
#   value       = aws_route_table.hawil_private_route_table.id
# }

# # Security Group Outputs
# output "bastion_security_group_id" {
#   description = "The ID of the bastion host security group"
#   value       = aws_security_group.bastion_sg.id
# }

# # bastion host outputs
# output "bastion_host_id" {
#   description = "The ID of the bastion host"
#   value       = aws_instance.bastion_host.id
# }

# output "bastion_host_public_ip" {
#   description = "The public IP address of the bastion host"
#   value       = aws_instance.bastion_host.public_ip
# }

# # private instance outputs 
# output "private_instance_id" {
#   description = "The ID of the private instance"
#   value       = aws_instance.private_ec2.id
# }
# output "private_instance_private_ip" {
#   description = "The private IP address of the private instance"
#   value       = aws_instance.private_ec2.private_ip
# }
