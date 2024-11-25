# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.main_vpc_cidr
  tags = {
    Name = var.main_vpc_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnet
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet__${count.index}"
  }
}

# Private subnet  
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private_subnet__${count.index}"
  }
}

# Internet Gateway  
resource "aws_internet_gateway" "main_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main_vpc_igw"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "main_vpc_ngw" {

  subnet_id = aws_subnet.public_subnet[0].id
  tags = {
    Name = "main_vpc_ngw"
  }
}

# Route Table
# Route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = var.all_access_cidr_block
    gateway_id = aws_internet_gateway.main_vpc_igw.id
  }

  route {
    cidr_block = var.local_cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "public_route_table"
  }
}

# Route table for main
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = var.local_cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "main_route_table"
  }
}

# Route table for private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = var.all_access_cidr_block
    nat_gateway_id = aws_nat_gateway.main_vpc_ngw.id
  }

  route {
    cidr_block = var.local_cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "private_route_table"

  }
}

# Route Table Association
# Route table assoc for public subnet
resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Route table asspc for private subnet
resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Nlb
resource "aws_lb" "public_nlb" {

  name               = "public-nlb"
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.public_subnet[0].id
  }
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "nlb_target_group" {
  name     = "nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.public_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_target_group.arn
  }
}

# Security Group
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3360
    to_port     = 3360
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidr_blocks
  }

  tags = {
    Name = "rds_sg"
  }
}

resource "aws_security_group" "ssm_host_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3360
    to_port     = 3360
    protocol    = "tcp"
    cidr_blocks = [var.all_access_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_access_cidr_block]
  }

  tags = {
    Name = "ssm_host_sg"
  }
}

resource "aws_security_group" "ssm_port_foward_sg" {
  name = "ssm_port_foward_sg"

  ingress {
    from_port   = 3360
    to_port     = 3360
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "rds_subnet_group"
  }
}



