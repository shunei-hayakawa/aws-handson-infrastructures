# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "sbcntrVpc"
  }
}

# Ingress Subnet, Route Table
resource "aws_subnet" "ingress_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.0.0/24"
  tags = {
    "Name" = "sbcntr-subnet-public-ingress-1a"
  }
}

resource "aws_subnet" "ingress_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.1.0/24"
  tags = {
    "Name" = "sbcntr-subnet-public-ingress-1c"
  }
}

resource "aws_route_table" "ingress" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    "Name" = "sbcntr-route-ingress"
  }
}

resource "aws_route_table_association" "ingress_1a" {
  subnet_id      = aws_subnet.ingress_1a.id
  route_table_id = aws_route_table.ingress.id
}

resource "aws_route_table_association" "ingress_1c" {
  subnet_id      = aws_subnet.ingress_1c.id
  route_table_id = aws_route_table.ingress.id
}

# Container Subnet, Route Table
resource "aws_subnet" "container_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.8.0/24"
  tags = {
    "Name" = "sbcntr-subnet-private-container-1a"
  }
}

resource "aws_subnet" "container_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.9.0/24"
  tags = {
    "Name" = "sbcntr-subnet-private-container-1c"
  }
}

resource "aws_route_table" "container" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "sbcntr-route-container"
  }
}

resource "aws_route_table_association" "container_1a" {
  subnet_id      = aws_subnet.container_1a.id
  route_table_id = aws_route_table.container.id
}

resource "aws_route_table_association" "container_1c" {
  subnet_id      = aws_subnet.container_1c.id
  route_table_id = aws_route_table.container.id
}

# DB Subnet, Route Table
resource "aws_subnet" "db_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.16.0/24"
  tags = {
    "Name" = "sbcntr-subnet-private-db-1a"
  }
}

resource "aws_subnet" "db_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.17.0/24"
  tags = {
    "Name" = "sbcntr-subnet-private-db-1c"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "sbcntr-route-db"
  }
}

resource "aws_route_table_association" "db_1a" {
  subnet_id      = aws_subnet.db_1a.id
  route_table_id = aws_route_table.db.id
}

resource "aws_route_table_association" "db_1c" {
  subnet_id      = aws_subnet.db_1c.id
  route_table_id = aws_route_table.db.id
}

# Management Subnet, Route Table
resource "aws_subnet" "management_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.240.0/24"
  tags = {
    "Name" = "sbcntr-subnet-public-management-1a"
  }
}

resource "aws_subnet" "management_1c" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.241.0/24"
  tags = {
    "Name" = "sbcntr-subnet-public-management-1c"
  }
}

resource "aws_route_table_association" "management_1a" {
  subnet_id      = aws_subnet.management_1a.id
  route_table_id = aws_route_table.ingress.id
}

resource "aws_route_table_association" "management_1c" {
  subnet_id      = aws_subnet.management_1c.id
  route_table_id = aws_route_table.ingress.id
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "sbcntr-igw"
  }
}

# Security Group
resource "aws_security_group" "ingress" {
  vpc_id = aws_vpc.main.id
  name   = "ingress"
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    ipv6_cidr_blocks = ["::/0"]
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
  }

  tags = {
    "Name" = "sbcntr-sg-ingress"
  }
}

resource "aws_security_group" "container" {
  vpc_id = aws_vpc.main.id
  name   = "container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.internal.id]
  }

  tags = {
    Name = "sbcntr-sg-container"
  }
}

resource "aws_security_group" "frontend_container" {
  name   = "frontend-container"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.ingress.id]
  }

  tags = {
    Name = "sbcntr-sg-frontend-container"
  }
}

resource "aws_security_group" "management" {
  name   = "management"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sbcntr-sg-management"
  }
}

resource "aws_security_group" "internal" {
  name   = "internal"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_container.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.management.id]
  }

  tags = {
    Name = "sbcntr-sg-internal"
  }
}

resource "aws_security_group" "database" {
  name   = "database"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.container.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.management.id]
  }

  tags = {
    Name = "sbcntr-sg-db"
  }
}

