variable "region" {
  default     = "us-west-2"
  description = "Region in AWS where our infra is created"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "Public subnet 1"
}

variable "public_subnet_2_cidr" {
  description = "Public subnet 2"
}

variable "public_subnet_3_cidr" {
  description = "Public subnet 3"
}

variable "private_subnet_1_cidr" {
  description = "Private subnet 1"

}

variable "private_subnet_2_cidr" {
  description = "Private subnet 2"

}
variable "private_subnet_3_cidr" {
  description = "Private subnet 3"

}