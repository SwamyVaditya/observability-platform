output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = "~/.kube/config"
}

output "cluster_name" {
  description = "Name of the K3D cluster"
  value       = var.cluster_name
}

output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = "argocd"
}

output "argocd_server_url" {
  description = "ClusterIP URL for Argo CD server"
  value       = "https://argocd-server.argocd.svc.cluster.local"
}

output "observability_namespace" {
  description = "Namespace for observability workloads"
  value       = var.observability_namespace
}

output "helm_chart_versions" {
  description = "Pinned Helm chart versions used for dependencies"
  value       = var.helm_chart_versions
}
