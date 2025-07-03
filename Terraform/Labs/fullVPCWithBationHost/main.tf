# VPC Infrastructure for Hawil Project
# Creates a complete VPC setup with public and private subnets

resource "aws_vpc" "hawil_vpc" {
  cidr_block           = var.vpc_cidr  # Use variable for VPC CIDR block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "hawil-vpc"
  }
}

resource "aws_subnet" "hawil_public_subnet" {
  vpc_id                  = aws_vpc.hawil_vpc.id
  cidr_block              = var.public_subnet_cidr  # Use variable for public subnet CIDR block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "hawil-public-subnet"
    Type = "public"
  }
}

# resource "aws_subnet" "hawil_private_subnet" {
#   vpc_id            = aws_vpc.hawil_vpc.id
#   cidr_block        = var.private_subnet_cidr  # Use variable for private subnet CIDR block
#   availability_zone = "us-east-1a"

#   tags = {
#     Name = "hawil-private-subnet"
#     Type = "private"
#   }
# }

# resource "aws_internet_gateway" "hawil_internet_gateway" {
#   vpc_id = aws_vpc.hawil_vpc.id

#   tags = {
#     Name = "hawil-internet-gateway"
#   }
# }

# resource "aws_eip" "hawil_nat_eip" {
#   domain = "vpc"
#   depends_on = [ aws_internet_gateway.hawil_internet_gateway ]
#   tags = {
#     Name = "hawil-nat-eip"
#   }
# }

# resource "aws_nat_gateway" "hawil_nat_gateway" {
#   allocation_id = aws_eip.hawil_nat_eip.id
#   subnet_id     = aws_subnet.hawil_public_subnet.id

#   tags = {
#     Name = "hawil-nat-gateway"
#   }

#   depends_on = [aws_internet_gateway.hawil_internet_gateway]
# }

# resource "aws_route_table" "hawil_public_route_table" {
#   vpc_id = aws_vpc.hawil_vpc.id

#   tags = {
#     Name = "hawil-public-route-table"
#   }
# }

# resource "aws_route_table" "hawil_private_route_table" {
#   vpc_id = aws_vpc.hawil_vpc.id

#   tags = {
#     Name = "hawil-private-route-table"
#   }
# }

# resource "aws_route_table_association" "hawil_public_subnet_association" {
#   subnet_id      = aws_subnet.hawil_public_subnet.id
#   route_table_id = aws_route_table.hawil_public_route_table.id
# }

# resource "aws_route_table_association" "hawil_private_subnet_association" {
#   subnet_id      = aws_subnet.hawil_private_subnet.id
#   route_table_id = aws_route_table.hawil_private_route_table.id
# }

# resource "aws_route" "hawil_public_route" {
#   route_table_id         = aws_route_table.hawil_public_route_table.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.hawil_internet_gateway.id
# }

# resource "aws_route" "hawil_private_route" {
#   route_table_id         = aws_route_table.hawil_private_route_table.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.hawil_nat_gateway.id
# }


# #  Bastion Host SG in Puclic Subnet

# resource "aws_security_group" "bastion_sg" {
#   name        = "bastion-sg"
#   description = "Allow SSH from anywhere"
#   vpc_id      = aws_vpc.hawil_vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]  # Open to the world for SSH
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "bastion-sg"
#   }
# }


# #  Private EC2 SG (private SG)

# resource "aws_security_group" "private_sg" {
#   name        = "private-sg"
#   description = "Allow SSH only from bastion host"
#   vpc_id      = aws_vpc.hawil_vpc.id

#   ingress {
#     from_port       = 22
#     to_port         = 22
#     protocol        = "tcp"
#     security_groups = [aws_security_group.bastion_sg.id]  # Allow only from bastion SG
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "private-sg"
#   }
# }

#  Bastion Host in Public Subnet
# resource "aws_instance" "bastion_host" {
#   ami                    = "ami-05ffe3c48a9991133"  
#   instance_type          = var.instance_type  # Use variable for instance type
#   subnet_id              = aws_subnet.hawil_public_subnet.id
#   vpc_security_group_ids = [aws_security_group.bastion_sg.id]
#   key_name               = "assem"  # Replace with your key pair name

#   tags = {
#     Name = "bastion-host"
#   }
# }
# #  Private EC2 Instance in Private Subnet
# resource "aws_instance" "private_ec2" {
#   ami                    = "ami-05ffe3c48a9991133"
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.hawil_private_subnet.id
#   vpc_security_group_ids = [aws_security_group.private_sg.id]
#   key_name               = "assem"

#   tags = {
#     Name = "private-ec2"
#   }
# }