resource "aws_subnet" "public_subnet" {
  count = 3
  vpc_id  = aws_vpc.main.id
  cidr_block = var.public_subnet[count.index]
  map_public_ip_on_launch = true
  availability_zone = var.AZ[count.index]
  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_route_table" "public_subnet" {
  count = 3
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_subnet_routable_${count.index}"
  }
}



resource "aws_route_table_association" "public_subnet" {
  count = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_subnet[count.index].id
}



resource "aws_subnet" "private_subnet" {
  count = 3
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet[count.index]
  availability_zone = var.AZ[count.index] 
  tags = {
    Name = "private_subnet_a_${count.index}"
  }
}

resource "aws_route_table" "private_subnet" {
  count = 3
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private[count.index].id
  }

  tags = {
    Name = "private_subnet_routable_${count.index}"
  }
}



resource "aws_route_table_association" "private_subnet" {
  count = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_subnet[count.index].id
}