terraform {
  required_version = ">= 1.8.0"

  required_providers {
    k3d = {
      source  = "pvotal-tech/k3d"
      version = ">= 0.0.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
  }
}

provider "k3d" {}
provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# -------------------------------
# K3D Cluster from cluster.yaml
# -------------------------------
resource "k3d_cluster" "observability" {
  name    = var.cluster_name
  servers = var.servers
  agents  = var.agents

  kubeconfig {
    update_default_kubeconfig = true
    switch_context            = true
  }

  config_yaml = file("${path.module}/../k3d/cluster.yaml")
}

# -------------------------------
# Prerequisite Helm charts
# -------------------------------
resource "helm_release" "calico" {
  name       = "calico"
  repository = "https://projectcalico.docs.tigera.io/charts"
  chart      = "tigera-operator"
  version    = var.helm_chart_versions["calico"]
  namespace  = "calico-system"
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.helm_chart_versions["cert_manager"]
  namespace  = "cert-manager"
  set {
    name  = "installCRDs"
    value = "true"
  }
}

# -------------------------------
# Argo CD install from manifest
# -------------------------------
resource "kubernetes_manifest" "argocd_install" {
  manifest = yamldecode(file("${path.module}/../argo-cd-install.yaml"))
}

# -------------------------------
# Argo CD Root App-of-Apps
# -------------------------------
resource "kubernetes_manifest" "argocd_root_app" {
  manifest = yamldecode(file("${path.module}/../argo-apps/root-app.yaml"))
  depends_on = [
    kubernetes_manifest.argocd_install
  ]
}


# -------------------------------
# Namespaces
# -------------------------------
resource "kubernetes_namespace" "observability" {
  metadata {
    name = var.observability_namespace
  }
}
