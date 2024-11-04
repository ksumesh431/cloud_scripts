# Fetch the availability zones dynamically for the region
data "aws_availability_zones" "available" {}

resource "aws_vpc" "kubeadm_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "kubeadm_vpc"
  }

  depends_on = [null_resource.ansible_pre_task]
}

# Create subnets across three AZs

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.kubeadm_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 0)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.kubeadm_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 1)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.kubeadm_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, 2)
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "private_subnet_3"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.kubeadm_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 3)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.kubeadm_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 4)
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_2"
  }
}
resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.kubeadm_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 4, 5)
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_3"
  }
}

###############################################################################
# INTERNET GATEWAY, ROUTE TABLE AND ROUTE TABLE ASSOCIATION TO PUBLIC SUBNET 
###############################################################################
resource "aws_internet_gateway" "kubeadm_igw" {
  vpc_id = aws_vpc.kubeadm_vpc.id

  tags = {
    Name = "kubeadm_igw"
  }
}

resource "aws_route_table" "kubeadm_routetable" {
  vpc_id = aws_vpc.kubeadm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubeadm_igw.id
  }

  tags = {
    Name = "kubeadm IGW route table"
  }

}

resource "aws_route_table_association" "kubeadm_route_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.kubeadm_routetable.id
}


###############################################################################
# EIP, NAT GATEWAY, ROUTE TABLE AND ROUTE TABLE ASSOCIATIONs TO PRIVATE SUBNETS 
###############################################################################

resource "aws_eip" "kubeadm_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.kubeadm_igw]

  tags = {
    Name = "kubeadm EIP"
  }
}

resource "aws_nat_gateway" "kubeadm_nat_gateway" {
  allocation_id = aws_eip.kubeadm_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.kubeadm_igw]
  tags = {
    Name = "kubeadm NAT Gateway"
  }
}

resource "aws_route_table" "kubeadm_private_routetable" {
  vpc_id = aws_vpc.kubeadm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.kubeadm_nat_gateway.id
  }

  tags = {
    Name = "kubeadm private route table"
  }

}

resource "aws_route_table_association" "kubeadm_private_route_association1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.kubeadm_private_routetable.id
}

resource "aws_route_table_association" "kubeadm_private_route_association2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.kubeadm_private_routetable.id
}

resource "aws_route_table_association" "kubeadm_private_route_association3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.kubeadm_private_routetable.id
}

