# Additional security group for worker nodes (if needed)
resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "${local.cluster_name}-worker-mgmt"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-worker-management"
  })
}
