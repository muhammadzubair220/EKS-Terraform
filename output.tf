output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.securezee.name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.securezee.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.securezee.vpc_config[0].cluster_security_group_id
}

output "kubectl_config" {
  description = "kubectl config command"
  value       = "aws eks update-kubeconfig --region us-east-1 --name ${aws_eks_cluster.securezee.name}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.securezee_vpc.id
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = aws_subnet.securezee_subnet[*].id
}

