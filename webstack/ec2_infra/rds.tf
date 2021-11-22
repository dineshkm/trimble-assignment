resource "aws_db_instance" "production_mysql" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.mysql_instance_type
  name                 = "ProductionMySqlDB"
  username             = var.mysql_username
  password             = var.mysql_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = data.terraform_remote_state.network_config.outputs.db_subnet_group
  vpc_security_group_ids =  [ aws_security_group.mysql_sg.id ]
}