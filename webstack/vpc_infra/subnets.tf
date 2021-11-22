# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "us-west-2b"
  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  cidr_block        = var.public_subnet_3_cidr
  availability_zone = "us-west-2c"
  vpc_id            = aws_vpc.production_vpc.id
  tags = {
    Name = "Public Subnet 3"
  }
}

#Private Subnets
resource "aws_subnet" "private_subnet_1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "us-west-2b"
  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  cidr_block        = var.private_subnet_3_cidr
  vpc_id            = aws_vpc.production_vpc.id
  availability_zone = "us-west-2c"
  tags = {
    Name = "Private Subnet 3"
  }
}

#Subnetgroup for redis
resource "aws_elasticache_subnet_group" "elastic_cache_subnet_group" {
  name       = "ElasticCache-Subnet-Group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
  tags = {
    Name = "Redis subnet group"
  }
}

#Subnetgroup for MySql
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]

  tags = {
    Name = "DB subnet group"
  }
}