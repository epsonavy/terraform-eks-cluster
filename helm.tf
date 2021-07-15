resource "helm_release" "ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  depends_on = [
    kubernetes_service.test
  ]
}

resource "null_resource" "after_deployment" {
  triggers = {
    helm_id = "${helm_release.ingress.id}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f kubernetes-ingress.yaml"
  }
}