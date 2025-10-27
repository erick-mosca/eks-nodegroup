output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${var.aws_region} update-kubeconfig --name ${module.eks.cluster_name}"
}

output "cluster_name" {
  description = "Cluster name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "K8s Cluster version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "oidc_provider" {
  description = "EKS OIDC Provider"
  value       = module.eks.oidc_provider
}

output "eks_managed_node_groups" {
  description = "EKS managed node groups"
  value       = module.eks.eks_managed_node_groups
}

output "oidc_provider_arn" {
  description = "EKS OIDC Provider Arn"
  value       = module.eks.oidc_provider_arn
}

output "cluster_status" {
  description = "EKS Cluster Status"
  value       = module.eks.cluster_status
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}