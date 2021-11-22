output "vpc_id" {
  value = aws_vpc.production_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.production_vpc.cidr_block
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_subnet_2.id
}

output "public_subnet_3" {
  value = aws_subnet.public_subnet_3.id
}

output "private_subnet_1" {
  value = aws_subnet.private_subnet_1.id
}

output "private_subnet_2" {
  value = aws_subnet.private_subnet_2.id
}

output "private_subnet_3" {
  value = aws_subnet.private_subnet_3.id
}

output "redis_subnet_group" {
  value = aws_elasticache_subnet_group.elastic_cache_subnet_group.id
}

output "db_subnet_group" {
  value = aws_db_subnet_group.db_subnet_group.id
}