resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.main.id

  #Route for IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "TF Public Subnets Route Table"
  }
}

resource "aws_route_table" "priv_route" {
  vpc_id = aws_vpc.main.id

  #`````````````````````````````
  #Route for NAT Gateway
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.NATgw.id
  # }


  tags = {
    Name = "TF Private Subnets Route Table"
  }
}

#Route table Associations
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.pub_1.id
  route_table_id = aws_route_table.pub_route.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.pub_2.id
  route_table_id = aws_route_table.pub_route.id
}

resource "aws_route_table_association" "priv1" {
  subnet_id      = aws_subnet.priv_1.id
  route_table_id = aws_route_table.priv_route.id
}
resource "aws_route_table_association" "priv2" {
  subnet_id      = aws_subnet.priv_2.id
  route_table_id = aws_route_table.priv_route.id
}
