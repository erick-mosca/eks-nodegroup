# resource "helm_release" "ingress-nginx" {
#   depends_on       = [module.eks]
#   name             = "ingress-nginx"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   namespace        = "ingress-nginx"
#   version          = "4.13.3"
#   create_namespace = true

#   set {
#     name  = "controller.service.type"
#     value = "NodePort"
#   }
#   set {
#     name  = "controller.service.nodePorts.http"
#     value = 30082
#   }

#   set {
#     name  = "controller.service.nodePorts.https"
#     value = 31757
#   }
# }

# resource "helm_release" "cert-manager" {
#   depends_on       = [helm_release.ingress-nginx]
#   name             = "cert-manager"
#   repository       = "https://charts.jetstack.io"
#   chart            = "cert-manager"
#   namespace        = "cert-manager"
#   version          = "v1.19.0"
#   create_namespace = true
#   set {
#     name  = "crds.enabled"
#     value = "true"
#   }

# }

# resource "helm_release" "letsencrypt" {
#   depends_on = [helm_release.cert-manager]
#   name       = "letsencrypt"
#   repository = "https://devpro.github.io/helm-charts"
#   chart      = "letsencrypt"
#   namespace  = "cert-manager"
#   version    = "0.1.4"

#   set {
#     name  = "registration.emailAddress"
#     value = "url@email.com"
#   }
# }

# resource "helm_release" "rancher" {
#   depends_on       = [helm_release.letsencrypt]
#   name             = "rancher"
#   repository       = "https://releases.rancher.com/server-charts/latest"
#   chart            = "rancher"
#   version          = "2.12.2"
#   namespace        = "cattle-system"
#   create_namespace = true

#   set {
#     name  = "hostname"
#     value = "uol.com.br"
#   }

#   set {
#     name  = "ingress.extraAnnotations.cert-manager\\.io/cluster-issuer"
#     value = "letsencrypt-hlg"
#   }

#   set {
#     name  = "ingress.ingressClassName"
#     value = "nginx"
#   }

#   set {
#     name  = "ingress.tls.source"
#     value = "letsEncrypt"
#   }
#   set {
#     name  = "ingress.tls.secretName"
#     value = "rancher-tls"
#   }
# }