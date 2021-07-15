#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.demo-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demo.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demo.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

# output "config_map_aws_auth" {
#   value = local.config_map_aws_auth
# }

output "kube_endpoint" {
  value = aws_eks_cluster.demo.endpoint
}

output "db_url" {
  value       = aws_db_instance.database.endpoint
  description = "endpoint of the db"
}

output "db_username" {
  value       = aws_db_instance.database.username
  description = "username of the db"
}

output "db_password" {
  value       = aws_db_instance.database.password
  description = "password of the db"
  sensitive   = true
}

output "db_config" {
  value = {
    user     = aws_db_instance.database.username
    password = aws_db_instance.database.password
    database = aws_db_instance.database.name
    hostname = aws_db_instance.database.address
    port     = aws_db_instance.database.port
  }
  sensitive = true
}

# output "kubeconfig" {
#   value = local.kubeconfig
# }

output "publicIP" {
  value = helm_release.ingress.id
}

# Done
# Install aws-iam-authenticator

# CMD
# kubectl get pods --all-namespaces
# kubectl config set-context --current --namespace=hello-world
# kubectl get pod -o wide

# TO DO
# find a way to use local-exec to run following
# terraform output -raw kubeconfig > ~/.kube/config

# https://stackoverflow.com/questions/67364542/how-to-expose-an-ingress-on-kuberntes-to-get-the-public-ip-address
# install the ingress controller basically which handles and manages the ingress object.
# there are multiple ingress controllers available in the market for the Kubernetes you can use one of as per need.

# https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/

# so your whole traffic whole will be something like
# internet > ingress > ingress controller > Kubernetes service > pod >  container
#...

# Note 07/15/2021
# https://kubernetes.github.io/ingress-nginx/deploy/#aws
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# install ingress-nginx from helm
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update

# helm install ingress-nginx ingress-nginx/ingress-nginx




# kubectl get pod nginxdemos-deployment-8458bcd645-r6x5r -o json |jq .status.hostIP