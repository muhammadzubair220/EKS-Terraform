# SecureZee EKS Infrastructure

Production-ready Amazon EKS cluster infrastructure provisioned with Terraform.

## Architecture

- **Region**: US East 1 (us-east-1)
- **VPC**: 10.0.0.0/16 CIDR
- **Subnets**: 2 public subnets across AZs
- **EKS Version**: Latest supported
- **Node Group**: 3 t2.medium instances

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl
- SSH key pair in AWS

## Variables

Create `terraform.tfvars`:
```hcl
ssh_key_name = "your-key-name"
```

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

## Post-Deployment

```bash
aws eks update-kubeconfig --region us-east-1 --name securezee-cluster
kubectl get nodes
```

## Resources Created

- VPC with Internet Gateway
- 2 Public Subnets
- Security Groups
- EKS Cluster
- Managed Node Group
- IAM Roles and Policies

## Cleanup

```bash
terraform destroy
```