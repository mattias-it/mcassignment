module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = [var.instance_type]
    
    # Disk configuration
    disk_size = 20
    disk_type = "gp3"
    
    # AMI configuration
    ami_type = "AL2023_x86_64_STANDARD"
    
    # Security group rules
#    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    main = {
      name = "main-node-group"
      
      min_size     = var.min_capacity
      max_size     = var.max_capacity
      desired_size = var.desired_capacity

      instance_types = [var.instance_type]
      capacity_type  = "ON_DEMAND"

      # Launch template configuration
      launch_template_name            = "${local.cluster_name}-node-group"
      launch_template_use_name_prefix = true
      launch_template_version         = "$Latest"

      labels = {
        Environment = "dev"
        NodeGroup   = "main"
      }

      tags = local.tags
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = local.tags
}
