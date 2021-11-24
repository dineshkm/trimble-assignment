variable "lambda_file_name" {
    description = "File name of the lambda needs to be uploaded"
    default = "compliance_check.py.zip"
}

variable "lambda_function_name" {
  description = "Function name of the lambda needs to be invoked"
  default = "ec2_compliance_check"
}