resource "aws_iam_role" "ec2_iam_role" {
  name = "ec2-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "iam_role_policy" {
  name   = "iam-role-policy"
  role   = aws_iam_role.ec2_iam_role.id
  policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Effect" : "Allow",
            "Action" : [
                "ec2:*",
                "elasticloadbalancing:*",
                "rds:*",
                "elasticache:*"
            ],
            "Resource": "*"
        }
    ]
}
  EOF
}
