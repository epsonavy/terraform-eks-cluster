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
  value = "${aws_eks_cluster.demo.endpoint}"
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
  sensitive   = true
}

output "kubeconfig" {
  value = local.kubeconfig
}

# Done
# Install aws-iam-authenticator

# TO DO
# find a way to use local-exec to run following
# terraform output -raw kubeconfig > ~/.kube/config

# provider "kubectl" {
#   load_config_file       = false
#   host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
#   token                  = "${data.google_container_cluster.my_cluster.access_token}"
#   cluster_ca_certificate = "${base64decode(data.google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)}"
# }

# resource "kubectl_manifest" "my_service" {
#     yaml_body = file("${path.module}/my_service.yaml")
# }
