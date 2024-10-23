
#`````````````````````````````
# resource "aws_nat_gateway" "NATgw" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.pub_1.id

#   tags = {
#     Name = "TF NAT gateway"
#   }

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.igw]
# }

#`````````````````````````````
# Elastic IP Resource
# resource "aws_eip" "eip" {
#   vpc      = true
#   depends_on = [aws_internet_gateway.igw]
# }