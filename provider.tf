provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.tags
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

# Provider do cluster Fargate
# provider "kubernetes" {
#   alias                  = "fargate"
#   host                   = module.eks_fargate.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks_fargate.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.fargate.token
# }

# # Auth do cluster Fargate
# data "aws_eks_cluster_auth" "fargate" {
#   name = module.eks_fargate.cluster_name
# }

# provider "helm" {
#   alias = "fargate"

#   kubernetes {
#     host                   = module.eks_fargate.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks_fargate.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.fargate.token
#   }
# }