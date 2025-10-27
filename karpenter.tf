# module "karpenter" {
#   source          = "terraform-aws-modules/eks/aws//modules/karpenter"
#   cluster_name    = module.eks_fargate.cluster_name
#   version         = "20.37.1"
#   create_iam_role = true
#   namespace       = "karpenter"
#   node_iam_role_additional_policies = {
#     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   }
#   tags = {
#     "karpenter.sh/discovery" = "${var.eks_cluster_name}"
#   }
# }

# resource "helm_release" "karpenter" {
#   create_namespace = true
#   name             = "karpenter"
#   repository       = "oci://public.ecr.aws/karpenter"
#   version          = "1.6.3"
#   chart            = "karpenter"
#   namespace        = "karpenter"


#   set {
#     name  = "settings.clusterName"
#     value = module.eks_fargate.cluster_name
#   }

#   set {
#     name  = "settings.clusterEndpoint"
#     value = module.eks_fargate.cluster_endpoint
#   }

#     set {
#       name  = "serviceAccount.annotations.eks\\amazonaws\\com/role-arn"
#       value = module.karpenter.node_iam_role_name
#     }
#   set {
#     name  = "settings.interruptionQueueName"
#     value = module.karpenter.queue_name
#   }
#   set {
#     name  = "settings.featureGates.spotToSpotConsolidation"
#     value = true
#   }
# }

# resource "kubectl_manifest" "karpenter_services_ec2_node_class" {
#   yaml_body = <<YAML
# apiVersion: karpenter.k8s.aws/v1
# kind: EC2NodeClass
# metadata:
#   name: services
# spec:
#   role: ${module.karpenter.node_iam_role_name}
#   amiFamily: AL2023
#   amiSelectorTerms:
#     - alias: al2023@latest
#   securityGroupSelectorTerms:
#   - id: sg-0d2510056f317ed8b
#   subnetSelectorTerms:
#     - id: subnet-083ab2c2ae6c8a549
#     - id: subnet-0623a8078918140f8
#   blockDeviceMappings:
#   - deviceName: /dev/xvda
#     ebs:
#       volumeSize: ${var.karpenter_volume_size_services}Gi
#       volumeType: gp3
#       iops: 3000
#       encrypted: true
#       deleteOnTermination: true
#       throughput: 125
#   tags:
#     KarpenterNodePoolName: services
#     NodeType: services
#     karpenter.sh/discovery: ${var.eks_cluster_name}
#     Name: eks-services-karpenter
#     terminate: "true"
# YAML
#   depends_on = [
#     resource.helm_release.karpenter,
#   ]
# }

# resource "kubectl_manifest" "karpenter_services_node_pool" {
#   yaml_body = <<YAML
# apiVersion: karpenter.sh/v1
# kind: NodePool
# metadata:
#   name: services 
# spec:  
#   template:
#     metadata:
#       labels:
#         karpenter: Exists
#         services: Exist
#         apps: Exist
#     spec:
#       limits:
#         cpu: "0"
#       kubelet:
#         maxPods: 110
#       requirements:
#         - key: kubernetes.io/arch
#           operator: In
#           values: ["amd64"]
#         - key: "karpenter.k8s.aws/instance-category"
#           operator: In
#           values: ["m"]
#         - key: "karpenter.k8s.aws/instance-family"
#           operator: In
#           values: ${jsonencode(var.karpenter_instance_family_services)}
#         - key: "karpenter.k8s.aws/instance-cpu"
#           operator: In
#           values: ["2"]
#         - key: karpenter.sh/capacity-type
#           operator: In
#           values: ["spot"]
#       nodeClassRef:
#         group: karpenter.k8s.aws
#         kind: EC2NodeClass
#         name: services
#   disruption:
#     consolidationPolicy: WhenEmptyOrUnderutilized
#     consolidateAfter: 60s
# YAML
#   depends_on = [
#     resource.helm_release.karpenter,
#   ]
# }