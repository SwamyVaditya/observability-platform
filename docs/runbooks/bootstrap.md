# Bootstrap Runbook — Observability Platform

This runbook describes the step‑by‑step process to bootstrap the **observability‑platform** infrastructure. It ensures a clean, reproducible setup for Kubernetes, GitOps, and observability workloads.

---

## 🛠 Prerequisites

- Docker installed and running
- Terraform `>= 1.8.0`
- kubectl `>= 1.29`
- Helm `>= 3.14`
- K3D CLI `>= 5.6`
- Git clone of this repository

---

## 🚀 Steps

### 1. Clone the repository
```bash
git clone https://github.com/SwamyVaditya/observability-platform.git
cd observability-platform/infra/terraform
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Apply Terraform to provision cluster + dependencies
```bash
terraform apply -auto-approve
```

This step:
- Creates a **K3D cluster** using `infra/k3d/cluster.yaml`
- Installs **Calico** for NetworkPolicies
- Installs **cert‑manager** with CRDs
- Applies **Argo CD install manifest** (`infra/argo-cd-install.yaml`)
- Creates the **observability namespace**
- Applies the **Argo CD root App‑of‑Apps manifest** (`argo-apps/root-app.yaml`)

> ⚡️ Note: The root App‑of‑Apps manifest is applied automatically by Terraform. No manual `kubectl apply` is required.

### 4. Verify cluster status
```bash
kubectl get nodes
kubectl get pods -A
```

Expected:
- All nodes in `Ready` state
- Calico pods running in `calico-system`
- cert‑manager pods running in `cert-manager`
- Argo CD pods running in `argocd`

### 5. Access Argo CD
```bash
kubectl get svc -n argocd
```

- Internal ClusterIP: `https://argocd-server.argocd.svc.cluster.local`
- For local access, port‑forward:
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```
  Then open: `https://localhost:8080`

### 6. Validate Observability Stack
```bash
kubectl get pods -n observability
```

Check that Loki, Grafana, Tempo, and Mimir pods are running.

---

## 📤 Outputs

Terraform provides key outputs:
- **kubeconfig_path** — `~/.kube/config`
- **cluster_name** — `observability-cluster`
- **argocd_namespace** — `argocd`
- **argocd_server_url** — `https://argocd-server.argocd.svc.cluster.local`
- **observability_namespace** — `observability`
- **helm_chart_versions** — pinned versions for Calico and cert‑manager

---

## 🧭 Notes

- Run `terraform destroy` to tear down the cluster cleanly.
- Ensure Docker has enough resources (CPU/RAM) for multi‑node K3D.
- Apply `PodDisruptionBudgets` and `NetworkPolicies` for production hardening.
- Use `helm upgrade` to bump chart versions when needed.

---

This runbook ensures a **repeatable bootstrap process** for the observability platform, with Argo CD taking over GitOps orchestration automatically.
