terraform {
  backend "s3" {
    bucket = "terraform-remote-state-20-11-2021"
    key    = "ec2_infra/infra.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform_state_lock"
  }
  required_providers {
    tls = {
        source = "hashicorp/tls"
        version = "3.1.0"
    }
    aws = {
        source  = "hashicorp/aws"
        version = "~> 3.27"
    }
  }
  required_version = ">= 0.13.5"
}

data "terraform_remote_state" "iam_config" {
  backend = "s3"
  config = {
    bucket = "terraform-remote-state-20-11-2021"
    key    = "iam_role/iam.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region
  access_key = data.terraform_remote_state.iam_config.outputs.iam_secret_id
  secret_key = data.terraform_remote_state.iam_config.outputs.iam_secret_access_key
  assume_role {
    role_arn     =  data.terraform_remote_state.iam_config.outputs.terraform_assume_role
    session_name = "TERRAFORM"    
  }
}

provider "tls" {
  # Configuration options
}
data "terraform_remote_state" "network_config" {
  backend = "s3"
  config = {
    bucket = "terraform-remote-state-20-11-2021"
    key    = "vpc_infra/infra.tfstate"
    region = "us-west-2"
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2-IAM-Instance-profile"
  role = aws_iam_role.ec2_iam_role.name

}

resource "aws_launch_configuration" "ec2_public_launchconfiguration" {
  image_id                    = var.ec2_image_id
  instance_type               = var.ec2_instance_type
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups             = [aws_security_group.public_sg.id]
  lifecycle {
    create_before_destroy = true
  } 
  user_data                   = <<EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    service httpd start
    chkconfig httpd on
    export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
    echo "<html><body><h1>Hello from Production web app instance <b>"$INSTANCE_ID"</b></h1></body></html>" >> /var/www/html/index.html
    EOF   
}

resource "aws_lb" "webapp_load_balancer" {
  name            = "production-webapp-load-balancer"
  internal        = false
  security_groups = [aws_security_group.elb_security_group.id]
  subnets = [data.terraform_remote_state.network_config.outputs.public_subnet_1,
    data.terraform_remote_state.network_config.outputs.public_subnet_2,
    data.terraform_remote_state.network_config.outputs.public_subnet_3
  ]
}



resource "aws_lb_listener" "webapp_load_balancer_listener" {
  load_balancer_arn = aws_lb.webapp_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.elb_acm_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_load_balancer_target_group.arn
  }
}

resource "aws_lb_target_group" "webapp_load_balancer_target_group" {
  name     = "webapp-load-balancer-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network_config.outputs.vpc_id

  health_check {
    healthy_threshold   = 5
    interval            = 30
    path                = "/index.html"
    timeout             = 5
    unhealthy_threshold = 5
  }
}
resource "aws_autoscaling_group" "ec2_public_asg" {
  name = "Production-WebApp-ASG"
  vpc_zone_identifier = [data.terraform_remote_state.network_config.outputs.public_subnet_1,
    data.terraform_remote_state.network_config.outputs.public_subnet_2,
    data.terraform_remote_state.network_config.outputs.public_subnet_3
  ]
  launch_configuration = aws_launch_configuration.ec2_public_launchconfiguration.name
  max_size             = var.max_instance_size
  min_size             = var.min_instance_size
  health_check_type    = "ELB"
  target_group_arns    = [ aws_lb_target_group.webapp_load_balancer_target_group.arn ]
  tags = [
    {
      key                 = "Name"
      propagate_at_launch = false
      value               = "WebApp-EC2-Instance"
    },
    {
      key                 = "Type"
      propagate_at_launch = false
      value               = "WebApp"
    }
  ]
}