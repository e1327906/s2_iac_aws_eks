output "cluster_name" {
  value = aws_eks_cluster.example.name
}

output "node_group_name" {
  value = aws_eks_node_group.example.node_group_name
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}
