# trimble-assignment

## Web Stack
### Prerequisities
Webstack assumes s3 bucket to store terraform.tfstate is created already. So, before running terraform code, please create s3 bucket in the name
> terraform-remote-state-20-11-2021

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

