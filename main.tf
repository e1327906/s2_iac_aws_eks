provider "aws" {
  region = "ap-southeast-1"
}

# Data sources to get existing VPC and subnets
data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnets" "existing" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

# EKS Cluster
resource "aws_eks_cluster" "example" {
  name     = var.cluster_name
  role_arn  = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = data.aws_subnets.existing.ids
  }

  tags = {
    Name = var.cluster_name
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster" {
  name = "EKSClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

# IAM Role for EKS Node Group
#resource "aws_iam_role" "eks_node_role" {
  #name = "AmazonEKSNodeRole"

  #assume_role_policy = jsonencode({
    #Version = "2012-10-17"
    #Statement = [
      #{
        #Action    = "sts:AssumeRole"
        #Effect    = "Allow"
        #Principal = {
          #Service = "ec2.amazonaws.com"
        #}
      #},
    #]
  #})
#}

# Use existing IAM Role for EKS Node Group
data "aws_iam_role" "eks_node_role" {
  name = "AmazonEKSNodeRole"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_instance_profile" "eks_node_profile" {
  name = "eks-node-instance-profile"
  role = aws_iam_role.eks_node_role.name
}

# EKS Node Group
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids       = data.aws_subnets.existing.ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = ["t3.small"]

  tags = {
    Name = var.node_group_name
  }
}
