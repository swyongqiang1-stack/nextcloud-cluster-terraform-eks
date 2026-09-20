resource "aws_eip" "lb" {
  count = 3
  domain   = "vpc"
}



resource "aws_nat_gateway" "private" {
  count = 3
  allocation_id = aws_eip.lb[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [
    aws_internet_gateway.gw
    ]
}
