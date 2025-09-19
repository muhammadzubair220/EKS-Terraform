output "cluster_id" {
  value = aws_eks_cluster.securezee.id
}

output "node_group_id" {
  value = aws_eks_node_group.securezee.id
}

output "vpc_id" {
  value = aws_vpc.securezee_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.securezee_subnet[*].id
}

