resource "aws_elasticache_cluster" "elastic_cache_redis" {
  cluster_id           = "elastic-cache-redis"
  engine               = "redis"
  node_type            = var.redis_instance_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  subnet_group_name    = data.terraform_remote_state.network_config.outputs.redis_subnet_group
  security_group_ids   = [aws_security_group.elastic_cache_sg.id]
}