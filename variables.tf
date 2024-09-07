variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
  default     = "vpc-0c229f5efeea9aea5"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "eks_cluster_demo"
}

variable "node_group_name" {
  description = "The name of the EKS node group"
  type        = string
  default     = "eks_node_group_demo"
}

variable "desired_size" {
  description = "The desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximumnumber of nodes in the node group"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "The minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "eks_node_role" {
  description = "The name of the EKS node role"
  type        = string
  default     = "AmazonEKSNodeRole"
}