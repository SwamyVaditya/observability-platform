# Terraform — Cluster Bootstrap (K3D + Argo CD)

This module bootstraps the **observability platform cluster** using Terraform. It provisions a K3D cluster, installs prerequisite Helm charts (Calico, cert‑manager), and deploys Argo CD with NetworkPolicy enforcement.

---

## 📖 Prerequisites

- **Terraform** `>= 1.8.0`
- **Docker** installed and running
- **K3D provider** (`pvotal-tech/k3d`)
- **Helm provider** (`hashicorp/helm`)
- **Kubernetes provider** (`hashicorp/kubernetes`)
- Cross‑platform support: works on **Windows**, **Linux**, and **macOS**

---

## ⚙️ Variables

Defined in [`variables.tf`](variables.tf):

- **cluster_name** — name of the K3D cluster (default: `observability`)
- **servers** — number of server nodes (default: `1`)
- **agents** — number of agent nodes (default: `2`)
- **storage_class** — default PVC storage class (default: `standard`)
- **argocd_namespace** — namespace for Argo CD (default: `argocd`)
- **observability_namespace** — namespace for observability workloads (default: `observability`)
- **helm_chart_versions** — pinned versions for Calico, cert‑manager, Argo CD

---

## 🚀 Usage

```bash
# Initialize providers and modules
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply -auto-approve
```

---

## 📦 Installed Components

- **Calico** — CNI plugin for NetworkPolicy enforcement
- **cert-manager** — TLS certificate management
- **K3D cluster** — 1 server + 2 agents, Traefik disabled
- **Argo CD** — GitOps control plane
- **NetworkPolicies** — deny‑all baseline, namespace ingress, DNS egress

---

## 📤 Outputs

Defined in infra/terraform/outputs.tf.

- **kubeconfig_path** — path to kubeconfig (`~/.kube/config`)
- **cluster_name** — name of the K3D cluster
- **argocd_namespace** — namespace for Argo CD
- **argocd_server_url** — internal ClusterIP URL for Argo CD server
- **observability_namespace** — namespace for observability workloads
- **helm_chart_versions** — pinned Helm chart versions

---

## 🧭 Notes

- **Cross‑platform**: Works on Windows, Linux, macOS with Docker installed.
- **Dependency ordering**: Helm releases (Calico, cert‑manager) installed before cluster creation; Argo CD installed after cluster is ready.
- **NetworkPolicy enforcement**: Calico ensures policies are applied correctly.
- **GitOps alignment**: Argo CD manifests are declarative and synced via App‑of‑Apps.

---
