# Demo App — Microservices with OpenTelemetry

This folder contains a **realistic demo microservices application** used to exercise the observability stack. It simulates a front‑end and two back‑end services, all instrumented with OpenTelemetry SDKs to emit **traces, logs, and metrics**.

---

## 📂 Structure

```
apps/demo-app/
├── frontend/              # Node.js frontend (Express/React)
│   ├── src/               # Application code
│   └── kustomize/         # Deployment manifests
├── backend-orders/        # Python FastAPI service (orders)
│   ├── src/
│   └── kustomize/
├── backend-users/         # Python FastAPI service (users)
│   ├── src/
│   └── kustomize/
└── kustomize/             # Top-level overlay for demo-app
```

---

## 🧩 Services

- **Frontend** (Node.js/Express)  
  Handles UI/API gateway, calls backends.  
- **Backend Orders** (Python FastAPI)  
  Simulates order management.  
- **Backend Users** (Python FastAPI)  
  Simulates user management.  

All services are instrumented with **OpenTelemetry SDKs** and export telemetry to the **Grafana Alloy collector** via OTLP.

---

## 🔗 Tracing Flow

1. A request hits the **frontend** (`/place-order`).  
2. Frontend calls **backend-orders** (`/orders`).  
3. Backend-orders calls **backend-users** (`/users`).  
4. Each hop emits spans with `trace_id` propagated.  
5. Traces flow into **Tempo**, logs into **Loki**, metrics into **Mimir**, dashboards in **Grafana**.

---

## ⚖️ Resource Constraints

To fit local clusters (8 GB RAM, ~20 GB disk):

- **Frontend**: `requests.cpu: 100m`, `requests.memory: 128Mi`  
- **Backends**: `requests.cpu: 100m`, `requests.memory: 128Mi` each  
- **Limits**: `250m CPU / 256Mi memory` per service  
- **PVCs**: not required (stateless services)

---

## 🚀 Running Locally

1. Bootstrap cluster with Terraform (`infra/terraform`).  
2. Argo CD syncs `demo-app.yaml` from `argo-apps/`.  
3. Generate traffic:  
   ```bash
   curl http://frontend.demo-app.svc.cluster.local:3000/place-order
   ```
4. Observe:  
   - **Traces** in Tempo → Grafana Explore  
   - **Logs** in Loki → Grafana Explore  
   - **Metrics** in Mimir → Grafana dashboards  
   - **SLOs** enforced via Sloth/Pyrra  

---

## 🧭 Why This Matters

- **Realistic microservices**: Node.js + FastAPI simulate real service boundaries.  
- **End-to-end observability**: traces, logs, metrics unified via Alloy.  
- **GitOps orchestration**: demo app managed declaratively alongside observability stack.  
- **Resume-ready project**: shows platform engineering best practices with observability.  

---
