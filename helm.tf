resource "helm_release" "ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  depends_on = [
    kubernetes_service.test
  ]
}

# set kubectl config from terraform output
resource "null_resource" "after_output" {
  triggers = {
    name = "${var.cluster-name}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      mkdir ~/.kube && touch ~/.kube/config
      terraform output -raw kubeconfig > ~/.kube/config
    EOT
  }
}

# deploy ingress-nginx 
resource "null_resource" "after_deployment" {
  triggers = {
    helm_id = "${helm_release.ingress.id}"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f kubernetes-ingress.yaml"
  }
}

