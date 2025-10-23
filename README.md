# EKS sample app + declarative deployment pipeline
## Original assignment 

Please select one of the following exercises and provide your solution in a presentation for the team where your skills and experience are best displayed. Provide repository links, code and whatever means that we can use to assess your level of skill.


* Provision a small sample application in EKS and walk us through an incident scenario including detection, diagnosis and resolution.

	* Extra points: Provision the basic infrastructure using your preferred Infrastructure as Code tool.

	* More Extra points: Use a declarative (yaml) deployment pipeline in your favourite CI/CD engine to deploy the application.

---
This README.MD describes what I've done here. The `iac/` folder includes a readme.md that talks about the terraform part.  

## Repository and code description
- Infrastructure as Code: Terraform. `iac/` creates the cloud infrastructure required for the demo, EKS cluster, VPC/subnets, IAM roles, etc.
- Kubernetes manifests: `k8s/` contains multiple manifests but The GitHub Actions pipeline intentionally applies only `k8s/nginx.yaml` and `k8s/loadbalancer.yaml` the other YAML files are left ignored.
	- that's because while I was preparing the assignment, I intended to include a simple prometheus+graphana stack to simulate the monitoring of a web service through a White and Black box approach. But the complexity I faced with persistency and declaring the graphs via manifests, given the limited time I should spend and the fact that it was out of scope, made me desist, but I left them to evaluate my skills nevertheless. 
- Declarative CI/CD: a GitHub Actions workflow `.github/workflows/eks-deploy.yml` that:
  - Runs Terraform (when files under `iac/` changed).
  - Updates kubeconfig and applies the two K8s manifests. 
  - Uses a path filter (dorny/paths-filter) so terraform only runs when `iac/` changed, and kubectl only runs when `k8s/` changed.
- Safety and operational features:
  - Workflow runs Terraform first (if needed) and only then runs the K8s apply (if needed), preserving ordering when both sets of changes are pushed together.
  - Secrets are stored in GitHub Actions secrets (kept them all under secrets for simplicity)
  - Minimal, readable manifests (nginx + loadbalancer) to keep the demo focused on SRE processes rather than app complexity.


## How to review and run locally
1. Tools used on Windows 11:
	* VSCode
	* WSL Integration for VSCode
	* Ubuntu 24.04 LTS  through WSL2. 
		* git
		* unzip
		* [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html )
		  Used to authenticate and manage AWS from terminal.
		* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
		  To interact with your EKS cluster.
		* [eksctl](https://docs.aws.amazon.com/eks/latest/eksctl/installation.html)
		  CLI that simplifies creating EKS clusters (you can use it alone or to bootstrap Terraform).
		* [terraform](https://developer.hashicorp.com/terraform/install)
		  To provision infrastructure as code.
		* helm
		  kubernete's package manager

2. GitHub secrets for CI
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`
     - `AWS_REGION` - eu-north-1
     - `EKS_CLUSTER_NAME` - mc-eks-cluster

3. Run Terraform
```bash
git clone https://github.com/mattias-it/mcassignment
cd mcassignment/iac
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

4. Apply Kubernetes manifests
```bash
aws eks update-kubeconfig --region eu-north-1 --name mc-eks-cluster
kubectl apply -f k8s/nginx.yaml -f k8s/loadbalancer.yaml
kubectl get pods,svc -n default
```

### CI/CD logic
- The workflow uses dorny/paths-filter to detect changes under `iac/` and `k8s/`. That means:
  - Pushes that change only `iac/` run the Terraform steps and skip kubectl.
  - Pushes that change only `k8s/` skip Terraform and run only the K8s steps.
  - Pushes that change both run Terraform first.

### Design decisions and trade-offs
- Single workflow, single job: I chose a single job so Terraform and K8s steps run in sequence within the same runner. That keeps ordering simple and avoids separate-workflow orchestration.
- Simplicity over complexity: the app is intentionally simple to keep the focus on infra, pipeline, and incident handling.

This repo is intentionally compact so you can focus on the IaC, the declarative pipeline, and the incident playbook. 