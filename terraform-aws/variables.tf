variable "region" {
  type        = string
  default     = "eu-west-3"
  description = "AWS region"
}

variable "cluster_name" {
  type        = string
  default     = "free-tier-eks"
  description = "EKS cluster name"
}

variable "account_id" {
  type        = string
  description = "AWS account ID this stack is deployed into (builds the CI role ARN). Required (no default) so every apply explicitly targets one account — supply via -var-file per account."
}

variable "kubernetes_version" {
  type        = string
  default     = "1.33"
  description = "Kubernetes version for the EKS control plane"
}

### Networking
variable "eks_public_access_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to reach the EKS public API endpoint. Required (no default) so a real value must be supplied at apply time — never falls back to 0.0.0.0/0 by accident."
  default     = ["109.97.42.231/32"]
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  description = "CIDR blocks for the public subnets, one per AZ (used for the NAT Gateway and any internet-facing load balancers)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
  description = "CIDR blocks for the private subnets, one per AZ (worker nodes run here); only 2 AZs are used and a single shared NAT Gateway routes their egress to keep cost down"
}

### Worker nodes
variable "node_instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 instance type for worker nodes. t3.micro is free-tier eligible but its 1GiB of RAM is too tight for kubelet + system pods; t3.small (2GiB) is the smallest size that reliably runs"
}

variable "node_desired_size" {
  type        = number
  default     = 1
  description = "Desired number of worker nodes"
}

variable "node_min_size" {
  type        = number
  default     = 1
  description = "Minimum number of worker nodes"
}

variable "node_max_size" {
  type        = number
  default     = 2
  description = "Maximum number of worker nodes (headroom for rolling node group updates)"
}
