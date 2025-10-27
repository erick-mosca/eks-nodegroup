aws_region                         = "us-east-1"
cluster_version                    = "1.32"
eks_cluster_name                   = "eks-services-sandbox"
eks_node_group                     = "eks-ng"
instance_types                     = ["t3a.xlarge", "t3.xlarge"]
capacity_type                      = "SPOT"
vpc_id                             = "vpc-00000000000000000"
security_group_ids                 = ["sg-0000000000000000000"]
volume_size                        = 20
min_size                           = 2
max_size                           = 3
desired_size                       = 2
subnet_id                          = ["subnet-00000000000000000", "subnet-0000000000000000"]
karpenter_volume_size              = 30
karpenter_volume_size_services     = 50
karpenter_cpu_default              = "16"
karpenter_instance_family_services = ["m5", "m5a", "t3", "t3a", "m6i", "m6a", "m7i", "m7a"]
certificate_arn                    = "arn:aws:acm:us-east-1:0000000000:certificate/0000000000000000"

tags = {
  service                  = "kubernetes"
  managedby                = "tofu"
  env                      = "homologation"
  "karpenter.sh/discovery" = "eks"
}

# Autoscaling Attachement
## Taget Groups
services_attachement = "arn:aws:elasticloadbalancing:us-east-1:00000000000:targetgroup/services/000000000000000"
