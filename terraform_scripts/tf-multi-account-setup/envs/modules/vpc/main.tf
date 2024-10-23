resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "TF VPC"
  }
}

resource "aws_subnet" "pub_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.pub_1_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.pub_1_az

  tags = {
    Name = "TF Public subnet 1"
  }
}
resource "aws_subnet" "pub_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.pub_2_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.pub_2_az

  tags = {
    Name = "TF Public subnet 2"
  }
}
resource "aws_subnet" "priv_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.priv_1_cidr
  availability_zone       = var.priv_1_az

  tags = {
    Name = "TF Private subnet 1"
  }
}
resource "aws_subnet" "priv_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.priv_2_cidr
  availability_zone       = var.priv_2_az

  tags = {
    Name = "TF Private subnet 2"
  }
}
