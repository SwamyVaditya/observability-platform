# Observability Platform — GitOps App‑of‑Apps
*GitOps‑driven observability with LGTM + CNCF*

This repository demonstrates a **production‑style observability platform** built with Kubernetes, Argo CD, and the LGTM stack (Loki, Grafana, Tempo, Mimir), plus Grafana Alloy, SLOs, and Alertmanager. It uses the **App‑of‑Apps GitOps pattern** to declaratively manage all workloads.

---

## 📂 Repository Structure

```
observability-platform/
├── infra/
│   ├── terraform/              # Terraform bootstrap (K3D, Argo CD, Calico, cert-manager)
│   └── k3d/                    # K3D cluster config
│
├── argo-apps/                  # Argo CD Application CRs (App-of-Apps orchestration)
│   ├── root-app.yaml           # Root App-of-Apps manifest
│   ├── grafana-app.yaml        # Grafana child app
│   ├── mimir-app.yaml          # Mimir child app
│   ├── loki-app.yaml           # Loki child app
│   ├── tempo-app.yaml          # Tempo child app
│   ├── alloy-app.yaml          # Grafana Alloy collector
│   ├── demo-app.yaml           # Demo microservices app (frontend + backends)
│   ├── slo-app.yaml            # Sloth/Pyrra SLO definitions
│   └── alertmanager-app.yaml   # Alertmanager child app
│
├── apps/                       # Workload manifests (Helm/Kustomize overlays)
│   ├── grafana/                # Grafana deployment
│   ├── mimir/                  # Mimir deployment
│   ├── loki/                   # Loki deployment
│   ├── tempo/                  # Tempo deployment
│   ├── alloy/                  # Grafana Alloy collector
│   ├── demo-app/               # Demo microservices (Node.js frontend + FastAPI backends)
│   ├── slo/                    # Sloth/Pyrra SLO YAMLs
│   └── alertmanager/           # Alertmanager deployment
│
├── docs/
│   └── runbooks/
│       └── bootstrap.md        # Step-by-step bootstrap runbook
│
└── README.md                   # This file
```

---

## 🚀 Bootstrap Flow

1. **Terraform apply** provisions:
   - K3D cluster
   - Calico + cert-manager
   - Argo CD install
   - Root App‑of‑Apps manifest

2. **Argo CD syncs child apps**:
   - Grafana, Loki, Tempo, Mimir
   - Grafana Alloy collector
   - Demo microservices app
   - SLO definitions (Sloth/Pyrra)
   - Alertmanager

3. **Observability stack ready**:
   - Metrics, logs, traces unified via Alloy
   - Dashboards in Grafana
   - Alerts routed via Alertmanager
   - SLOs continuously evaluated

---

## ⚖️ Resource Constraints

This repo is tuned for local clusters with **8 GB RAM and ~20 GB disk**:

- PVC sizes downsized (Grafana, Loki, Mimir = 2Gi; Tempo = 1Gi)
- Resource requests/limits reduced (100m CPU / 256Mi memory typical)
- Retention policies shortened (logs 7d, traces 3d)

---

## 🧭 Why This Matters

- **GitOps orchestration**: Argo CD declaratively manages all workloads.  
- **Production-style stack**: Demonstrates Grafana + Loki + Tempo + Mimir + Alloy.  
- **Realistic demo app**: Node.js frontend + Python FastAPI backends emit real traces/logs.  
- **SLO-driven alerts**: Error budgets and objectives codified in YAML.  
- **Recruiter-friendly documentation**: Shows platform engineering best practices.  

---

## 🧭 Notes

- **Cross‑platform**: Works on Windows, Linux, macOS with Docker installed.  
- **Dependency ordering**: Helm charts (Calico, cert‑manager) installed before cluster creation; Argo CD installed after cluster is ready.  
- **Production hardening**: PVCs, PodDisruptionBudgets, NetworkPolicies included.  

---
