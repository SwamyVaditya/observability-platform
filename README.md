# Observability Platform — LGTM + CNCF
*GitOps‑driven observability with LGTM + CNCF*

This repository contains a **production‑grade observability platform** built using the **App‑of‑Apps pattern with Argo CD**. It integrates the **LGTM stack** (Loki, Grafana, Tempo, Mimir) with modern CNCF components, hardened for scale and reliability.

---

## 📖 Repository Description

The `observability-platform` repo demonstrates **platform engineering best practices**:
- **GitOps orchestration**: Argo CD App‑of‑Apps pattern manages infra and apps declaratively.
- **Observability stack**: Unified pipelines for metrics, logs, and traces.
- **SLOs as Code**: Availability and latency objectives defined via Sloth/Pyrra.
- **Production hardening**: Resource limits, persistence, PodDisruptionBudgets, NetworkPolicies.
- **Documentation**: Architecture diagrams, ADRs, and runbooks included for clarity and operational readiness.

---

## 📂 Repository Structure

```
observability-platform/
├── infra/
│   ├── terraform/                # Cluster bootstrap (K3D + Argo CD + NetworkPolicies)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── k3d/
│       └── cluster.yaml          # Raw K3D cluster definition (servers + agents + CNI)
│
├── argo-apps/
│   └── root-app.yaml             # App-of-Apps root manifest for GitOps orchestration
│
├── apps/
│   ├── demo-app/                 # Sample app instrumented with OpenTelemetry SDKs
│   ├── alloy/                    # Grafana Alloy collector (metrics/logs/traces)
│   ├── slo/                      # Sloth/Pyrra SLO definitions
│   └── alertmanager/             # Alertmanager child app manifest
│
├── docs/
│   ├── architecture.md           # High-level flow + mermaid diagram + screenshots
│   ├── adr/
│   │   └── 001-why-mimir-over-prometheus.md
│   └── runbooks/
│       ├── availability.md       # Runbook for availability SLO breach
│       └── latency.md            # Runbook for latency SLO breach
```

---

## 🚀 Quick Start

1. **Bootstrap cluster with Terraform**:
   ```bash
   cd infra/terraform
   terraform init
   terraform apply -auto-approve
   ```

2. **Verify K3D cluster**:
   ```bash
   kubectl get nodes
   ```

3. **Check Argo CD installation**:
   ```bash
   kubectl get pods -n argocd
   ```

4. **Sync App‑of‑Apps root manifest**:
   ```bash
   kubectl apply -f argo-apps/root-app.yaml
   ```

---

## 🔑 Key Features

- **App-of-Apps orchestration**: GitOps manages infra and apps declaratively.  
- **Unified collector**: Alloy handles metrics, logs, and traces.  
- **SLO-driven alerts**: Error budget burn alerts with runbooks.  
- **NetworkPolicy enforcement**: Calico ensures namespace isolation.  
- **Documentation**: ADRs, runbooks, and architecture docs included.  

---

## 📤 Outputs

Defined in infra/terraform/outputs.tf

- **kubeconfig_path** — path to kubeconfig (`~/.kube/config`)
- **cluster_name** — name of the K3D cluster
- **argocd_namespace** — namespace for Argo CD
- **argocd_server_url** — internal ClusterIP URL for Argo CD server
- **observability_namespace** — namespace for observability workloads
- **helm_chart_versions** — pinned Helm chart versions

---

## 🧭 Notes

- **Cross‑platform**: Works on Windows, Linux, macOS with Docker installed.  
- **Dependency ordering**: Helm charts (Calico, cert‑manager) installed before cluster creation; Argo CD installed after cluster is ready.  
- **Production hardening**: PVCs, PodDisruptionBudgets, NetworkPolicies included.  

---
