variable "aws_region" {
  type        = string
  description = "AWS region where the resources will be deployed (e.g., us-east-1)."
}

variable "cluster_version" {
  type        = string
  description = "Version of the EKS cluster (e.g., 1.24)."
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the EKS cluster."
}

variable "eks_node_group" {
  type        = string
  description = "Name of the EKS managed node group."
}

variable "instance_types" {
  type        = list(any)
  description = "List of EC2 instance types used for the EKS nodes (e.g., t3.medium)."
}

variable "capacity_type" {
  type        = string
  description = "Capacity type of the node group (e.g., 'ON_DEMAND' or 'SPOT')."
}

variable "security_group_ids" {
  type        = list(any)
  description = "List of security group IDs associated with the EKS cluster."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EKS cluster is deployed."
}

variable "volume_size" {
  type        = string
  description = "Size (in GB) of the root volume for EKS nodes."
}

variable "min_size" {
  type        = string
  description = "Minimum number of nodes in the EKS node group."
}

variable "max_size" {
  type        = string
  description = "Maximum number of nodes in the EKS node group."
}

variable "desired_size" {
  type        = string
  description = "Desired number of nodes in the EKS node group."
}

variable "subnet_id" {
  type        = list(any)
  description = "List of subnet IDs where the EKS cluster resources will be deployed."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all created resources."
}

variable "karpenter_cpu_default" {
  type        = string
  description = "CPU limit for the default node pool managed by Karpenter."
}

variable "karpenter_instance_family_services" {
  type        = list(any)
  description = "List of instance families used for service nodes."
}

variable "karpenter_volume_size" {
  type        = string
  description = "Disk space configuration for the default Karpenter node class."
}

variable "karpenter_volume_size_services" {
  type        = string
  description = "Disk space configuration for the services-specific Karpenter node class."
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the certificate used for SSL termination in NLB."
}

variable "services_attachement" {
  description = "Target group for autoscaling attachment"
  type        = string
}