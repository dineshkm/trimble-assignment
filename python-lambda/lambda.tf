provider "aws" {
    region = "us-west-2"  
}

# Creates IAM role and policies for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_access_policies" {
  name        = "lambda_access"
  path        = "/"
  description = "IAM policy for reading instances and upload to s3 from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "ec2:Describe*",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:*"            
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_access_policies.arn
}

# Create lambda function in AWS by uploading the code from local filesystem
resource "aws_lambda_function" "check_instances_lambda" {
  filename          = var.lambda_file_name
  function_name     = var.lambda_function_name
  role              = aws_iam_role.iam_for_lambda.arn
  source_code_hash  = filebase64sha256(var.lambda_file_name)
  runtime           = "python3.6"
  handler           = "compliance_check.lambda_handler"
  timeout           = 10
  environment {
    variables = {
      test = "False"        #Test parameter to trigger alert
    }
  }  
}

# Configure trigger for lambda
resource "aws_cloudwatch_event_rule" "twice_per_day" {
  name                = "twice-per-day"
  description         = "Triggers compliance check for ec2 instances twice per day"
  schedule_expression = "cron(0 */12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "check_instances_twice_per_day" {
  rule      = aws_cloudwatch_event_rule.twice_per_day.name
  target_id = "lambda"
  arn       = aws_lambda_function.check_instances_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_instances" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_instances_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.twice_per_day.arn  
}