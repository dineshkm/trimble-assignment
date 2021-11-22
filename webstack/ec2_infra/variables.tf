variable "region" {
  default     = "us-west-2"
  description = "AWS default region"
}

variable "ec2_instance_type" {
  description = "EC2 instance type to launch"
}

variable "ec2_image_id" {
  description = "EC2 image id"  
}

variable "max_instance_size" {
  description = "Maximum number of EC2 instances to launch"
}

variable "min_instance_size" {
  description = "Minimum number of EC2 instances to launch"
}
variable "mysql_instance_type" {
  description = "Instance type to launch mysql databse"
  default     = "db.t3.micro"
}

variable "mysql_username" {
  description = "Username for MySql database"
}

variable "mysql_password" {
  description = "Password for MySql database"
}

variable "redis_instance_type" {
  description = "Instance type to launch mysql databse"
  default     = "cache.m4.large"
}
