# Remote backend to store terraform state file
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-20-11-2021"
    key    = "vpc_infra/infra.tfstate"
    region = "us-west-2"
  }
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 3.27"
    }
  }
  required_version = ">= 0.13.5"
}

provider "aws" {
  region = var.region
}

#VPC
resource "aws_vpc" "production_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "production-vpc"
  }
}

#EIP for NAT Gateway
resource "aws_eip" "elastic_ip_for_nat_gw" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    Name = "Production-EIP"
  }
}

#Gateways
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip_for_nat_gw.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "Production-NAT-GW"
  }
  depends_on = [aws_eip.elastic_ip_for_nat_gw]
}

resource "aws_internet_gateway" "vpc_internet_gw" {
  vpc_id = aws_vpc.production_vpc.id
  tags = {
    Name = "Production-IGW"
  }

}
