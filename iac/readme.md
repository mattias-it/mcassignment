# iac/ - Terraform for EKS cluster
## High-level overview
- Purpose: Provision an AWS VPC, security groups, and an EKS cluster with managed node groups using community Terraform modules.
- Main components:
  - VPC and subnets (vpc.tf)
  - Security groups (security-groups.tf)
  - EKS cluster and managed node groups (eks.tf)
  - Variables and local values (variables.tf, main.tf)
  - Process Output values (output.tf)

---

## Files scopes

- main.tf
  - Hosts providers, local variables like `local.cluster_name`, `local.tags` and other shared bootstrap configuration referenced across modules.
- variables.tf
  - Declares input variables like `cluster_version`, `instance_type`, `min_capacity`, `max_capacity`, `desired_capacity`, that are used across  modules.
- vpc.tf
  - Creates or references a VPC and subnets that provides networking for the whole demo. 
- security-groups.tf
  - Defines security groups used for EKS control plane and/or nodes. Expected to manage inbound/outbound rules for worker nodes and cluster access.
- eks.tf
	- Uses `terraform-aws-modules/eks/aws` module to provision the cluster and managed node groups.
- output.tf
  - Exposes outputs needed locally, like kubeconfig, cluster endpoint/CA, node group details.


## Consideration on single source of truth 
Terraform relies on state files to discern its awareness over the platform it deployed. The current method, with a local machine and this workflow, isn't sustainable without a third party storing the state files, as in S3+DynamoDB. 