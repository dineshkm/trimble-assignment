# trimble-assignment

## Python Lambda

![Architecture Diagram](lambda_architecture.png)
### Prerequisities
Create bucket to upload inventory files to s3. And provide the bucket name in python code for the variable 'BUCKET'

### Python lambda
You can find the lambda function under python-lambda/compliance_check.py

### Create lambda using Terraform
Go to python-lambda folder and run the following commands
1. Run terraform init , plan and apply
```
terraform init
terraform plan
terraform apply
```


## Web Stack
### Prerequisities
Webstack assumes s3 bucket to store terraform.tfstate is created already. So, before running terraform code, please create s3 bucket in the name
> terraform-remote-state-20-11-2021

### Create IAM access for terraform
Go to webstack/iam_role folder and run the following commands
1. Run terraform init
```
terraform init
```

2. Run terraform validate to check the syntax and other static validations
```
terraform validate
```

3. Run terraform plan to inspect the necessary resources creation in AWS
```
terraform plan 
```

4. Run terraform apply to create resources in AWS
```
terraform apply 
```

### Create VPC infra
Go to webstack/vpc_infra folder and run the following commands
1. Run terraform init
```
terraform init
```

2. Run terraform validate to check the syntax and other static validations
```
terraform validate
```

3. Run terraform plan to inspect the necessary resources creation in AWS
```
terraform plan -var-file=production.tfvars
```

4. Run terraform apply to create resources in AWS
```
terraform apply -var-file=production.tfvars
```

### Create Application infra
Go to webstack/ec2_infra folder and run the following commands
1. Run terraform init
```
terraform init
```

2. Run terraform validate to check the syntax and other static validations
```
terraform validate
```

3. Run terraform plan to inspect the necessary resources creation in AWS
```
terraform plan -var-file=production.tfvars
```

4. Run terraform apply to create resources in AWS
```
terraform apply -var-file=production.tfvars
```