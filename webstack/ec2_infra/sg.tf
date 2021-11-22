resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow SSH, TCP and HTTP connections to Web App"
  vpc_id      = data.terraform_remote_state.network_config.outputs.vpc_id

  ingress = [{
    cidr_blocks      = []
    description      = "HTTP from ELB"
    from_port        = 80
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "TCP"
    security_groups  = [aws_security_group.elb_security_group.id]
    self             = false
    to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "SSH from VPC"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "TCP"
      security_groups  = []
      self             = false
      to_port          = 22
  }]

  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  tags = {
    "Name" = "Public-SG"
  }
}

resource "aws_security_group" "elb_security_group" {
  name        = "ELB-SG"
  description = "ELB Security Group"
  vpc_id      = data.terraform_remote_state.network_config.outputs.vpc_id
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow only HTTPS traffic from Internet"
    from_port        = 443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "TCP"
    security_groups  = []
    self             = false
    to_port          = 443
  }]
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}


resource "aws_security_group" "mysql_sg" {
  name        = "MySql-SG"
  description = "Enable connection to MySQL database"
  vpc_id      = data.terraform_remote_state.network_config.outputs.vpc_id
  ingress = [{
    cidr_blocks      = []
    description      = "Connection from WebApp"
    from_port        = 3306
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "TCP"
    security_groups  = [aws_security_group.public_sg.id]
    self             = false
    to_port          = 3306
  }]
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  tags = {
    "Name" = "MySql-SG"
  }
}

resource "aws_security_group" "elastic_cache_sg" {
  name        = "Redis-SG"
  description = "Enable connection to Elastic Cache Redis"
  vpc_id      = data.terraform_remote_state.network_config.outputs.vpc_id
  ingress = [{
    cidr_blocks      = []
    description      = "Connection from WebApp"
    from_port        = 6379
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "TCP"
    security_groups  = [aws_security_group.public_sg.id]
    self             = false
    to_port          = 6379
  }]
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
  tags = {
    "Name" = "Redis-SG"
  }
}