data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_ecrpublic_authorization_token" "token" {}

data "aws_availability_zones" "available" {}

################################################################################
#Cluster
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name                             = var.eks_cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  create_cloudwatch_log_group              = false


  cluster_addons = {
    aws-efs-csi-driver           = { most_recent = true }
    aws-ebs-csi-driver           = { most_recent = true }
    kube-proxy                   = { most_recent = true }
    coredns                      = { most_recent = true }
    aws-mountpoint-s3-csi-driver = { most_recent = true }
    vpc-cni = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id                                = var.vpc_id
  subnet_ids                            = var.subnet_id
  cluster_additional_security_group_ids = var.security_group_ids
  enable_irsa                           = true

  create_cluster_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    eks-sandbox-ng = {
      node_group_name = var.eks_node_group
      instance_types  = var.instance_types
      capacity_type   = var.capacity_type

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      create_security_group = true
      security_group_ids    = var.security_group_ids

      subnet_ids   = var.subnet_id
      desired_size = var.desired_size
      min_size     = var.min_size
      max_size     = var.max_size
      # Adicionando o script no pre_bootstrap_user_data
      pre_bootstrap_user_data = <<-EOT
        #!/bin/bash
          sed -i 's/\bnullok\b//g' /etc/pam.d/system-auth
          sed -i 's/\bnullok\b//g' /etc/pam.d/passwd
      EOT

      # Launch template configuration
      create_launch_template = true              # false will use the default launch template
      launch_template_os     = "amazonlinux2eks" # amazonlinux2eks or bottlerocket
      kubelet_extra_args     = "--node-labels=intent=control-apps"

      labels = {
        role     = var.eks_node_group
        services = "Exist"
      }

      # taints = {
      #   addons = {
      #     key    = "CriticalAddonsOnly"
      #     value  = "true"
      #     effect = "NO_SCHEDULE"
      #   }
      # }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/${var.eks_cluster_name}"  = "owned"
        "k8s.io/cluster-autoscaler/node-template/label/role" = "${var.eks_node_group}"
        "k8s.io/cluster-autoscaler/ssm/ssmmanaged"           = "true"
        "k8s.io/cluster-autoscaler/ssm/ssmactivation"        = "true"
        "karpenter.sh/discovery"                             = "${var.eks_cluster_name}"
        "terminate"                                          = "true"
      }
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        AmazonEC2FullAccess          = "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        AmazonEFSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        nodegroup_policy_karpenter   = resource.aws_iam_policy.nodegroup_policy_karpenter.arn
      }
    }
  }
}

resource "aws_iam_policy" "nodegroup_policy_karpenter" {
  name        = "nodegroup_policy_karpenter"
  path        = "/"
  description = "policy to karpenter scaling ec2"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateInstanceProfile",
          "iam:GetInstanceProfile",
          "pricing:GetProducts",
          "iam:TagInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:PassRole",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile"
        ],
        "Resource" : "*"
      }
    ]
  })
}

################################################################################
#EKS Metrics
################################################################################

resource "helm_release" "metrics-server" {
  depends_on = [module.eks]
  chart      = "metrics-server"
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  namespace  = "kube-system"

  # set {
  #   name  = "tolerations[0].key"
  #   value = "CriticalAddonsOnly"
  # }

  # set {
  #   name  = "tolerations[0].operator"
  #   value = "Exists"
  # }
}

################################################################################
# EFS Module
################################################################################

# module "efs" {
#   source = "terraform-aws-modules/efs/aws"

#   name = "efs-kubecost"
#   encrypted      = false
#   lifecycle_policy = {
#     transition_to_ia = "AFTER_30_DAYS"
#   }
#   mount_targets = {
#     "us-east-1a" = {
#       subnet_id = "subnet-07e26537964917e27"
#     }
#     "us-east-1b" = {
#       subnet_id = "subnet-080bc9939d3154add"
#     }
#   }
#   security_group_description = "EFS security group"
#   security_group_vpc_id      = var.vpc_id
#   security_group_rules = {
#     vpc = {
#       # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
#       description = "NFS ingress from VPC private subnets"
#       cidr_blocks = ["172.31.0.0/20", "172.31.80.0/20"]
#     }
#   }
#   # Backup policy
#   enable_backup_policy = false
# }



# resource "kubernetes_storage_class" "efs-sc" {
#   metadata {
#     name = "efs-sc"
#   }
#   storage_provisioner    = "efs.csi.aws.com"
#   parameters = {
#     provisioningMode = "efs-ap"
#     fileSystemId     = module.efs.id
#     directoryPerms   = "700"
#   }
# }