# Bootstrap Runbook — Observability Platform

This runbook describes how to bootstrap the **observability-platform** locally using Terraform, K3D, and Argo CD with the App‑of‑Apps GitOps pattern.

---

## 📂 Prerequisites

- Docker installed and running
- Terraform ≥ 1.5
- K3D ≥ 5.6
- kubectl ≥ 1.27
- Argo CD CLI (optional, for manual syncs)

---

## 🚀 Step 1 — Provision Cluster

Use Terraform to bootstrap the K3D cluster and install base components:

```bash
cd infra/terraform
terraform init
terraform apply -auto-approve
```

This provisions:
- K3D cluster (1 server + 2 agents)
- Calico CNI
- cert-manager
- Argo CD installation
- Root App‑of‑Apps manifest (`argo-apps/root-app.yaml`)

---

## 🔄 Step 2 — Verify Argo CD

Check Argo CD pods:

```bash
kubectl get pods -n argocd
```

Port-forward Argo CD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Login with default credentials (`admin` / initial password from pod logs).

---

## 📦 Step 3 — Sync Root App

The root app (`argo-apps/root-app.yaml`) declares all child apps. Sync it:

```bash
argocd app sync root-app
```

This deploys:
- Grafana, Loki, Tempo, Mimir
- Grafana Alloy collector
- Demo microservices app (frontend + backends)
- SLO definitions (Sloth/Pyrra)
- Alertmanager

---

## 📊 Step 4 — Generate Traffic

Send sample requests to exercise tracing:

```bash
kubectl port-forward svc/frontend -n observability 3000:3000
curl http://localhost:3000/place-order
```

This flows through:
- Frontend → Backend Orders → Backend Users
- Traces exported via Alloy → Tempo
- Logs → Loki
- Metrics → Mimir

---

## 📈 Step 5 — Observe in Grafana

Port-forward Grafana:

```bash
kubectl port-forward svc/grafana -n observability 3000:3000
```

Open `http://localhost:3000` [(localhost in Bing)](https://www.bing.com/search?q="http%3A%2F%2Flocalhost%3A3000%2F"):

- **Explore → Tempo**: view distributed traces
- **Explore → Loki**: view structured logs
- **Dashboards → Mimir**: view metrics
- **Alerting → Alertmanager**: view routed alerts
- **SLOs → Sloth/Pyrra**: view error budgets

---

## ⚖️ Resource Constraints

This stack is tuned for local clusters with **8 GB RAM and ~20 GB disk**:

- PVCs downsized (Grafana, Loki, Mimir = 2Gi; Tempo = 1Gi)
- Resource requests/limits reduced (100m CPU / 256Mi memory typical)
- Retention policies shortened (logs 7d, traces 3d)

---

## 🧭 Why This Matters

- **GitOps orchestration**: Argo CD declaratively manages all workloads.  
- **End-to-end observability**: Metrics, logs, traces unified via Alloy.  
- **Realistic demo app**: Node.js + FastAPI microservices emit real telemetry.  
- **Resume-ready project**: Shows platform engineering best practices with observability.  

---

## 🛠️ Troubleshooting

### Argo CD Sync Errors
- **Symptom**: `Application ... is OutOfSync` or sync fails.
- **Cause**: Repo URL misconfigured or missing `.git` suffix.
- **Fix**: Ensure `repoURL: 'https://github.com/SwamyVaditya/observability-platform.git'` in all child manifests.  
  Run:
  ```bash
  argocd app sync root-app
  ```

### PVC Quota Exceeded
- **Symptom**: Pods stuck in `Pending` due to PVC scheduling errors.
- **Cause**: Requested storage exceeds local disk.
- **Fix**: Verify downsized PVCs (Grafana, Loki, Mimir = 2Gi; Tempo = 1Gi).  
  Adjust in `values.yaml` if needed.

### Grafana Login Issues
- **Symptom**: Cannot log in to Grafana UI.
- **Cause**: Default admin password not retrieved.
- **Fix**: Get password from secret:
  ```bash
  kubectl get secret grafana -n observability -o jsonpath="{.data.admin-password}" | base64 -d
  ```

### Tempo Trace Not Visible
- **Symptom**: No traces in Grafana Explore → Tempo.
- **Cause**: OTLP exporter misconfigured or Alloy not reachable.
- **Fix**: Check Alloy service:
  ```bash
  kubectl get svc alloy -n observability
  ```
  Ensure demo-app services export to `http://alloy:4317`.

### Loki Logs Missing
- **Symptom**: No logs in Grafana Explore → Loki.
- **Cause**: Log client misconfigured.
- **Fix**: Verify Alloy Loki client URL:
  ```
  http://loki:3100/loki/api/v1/push
  ```

### Alertmanager Not Routing
- **Symptom**: Alerts not visible or not routed.
- **Cause**: Webhook receiver misconfigured.
- **Fix**: Check Alertmanager config in `apps/alertmanager/kustomize/values.yaml`.  
  Ensure webhook service is reachable.

---

## 🧭 Quick Debug Commands

- **Check pods**:
  ```bash
  kubectl get pods -n observability
  ```
- **Describe failing pod**:
  ```bash
  kubectl describe pod <pod-name> -n observability
  ```
- **View logs**:
  ```bash
  kubectl logs <pod-name> -n observability
  ```

---

## 🔑 Key References
- **Argo CD sync troubleshooting**
- **PVC scheduling issues**
- **Grafana admin password retrieval**
- **Tempo OTLP exporter setup**
- **Loki client push URL**
- **Alertmanager webhook routing**

---

## ✅ Validation Checklist

After completing bootstrap, run through this checklist to validate the stack:

### Cluster & Argo CD
- [ ] **Cluster nodes**: `kubectl get nodes` shows all nodes `Ready`.
- [ ] **Argo CD pods**: `kubectl get pods -n argocd` shows all pods `Running`.
- [ ] **Root app synced**: `argocd app list` shows `root-app` `Healthy` and `Synced`.

### Observability Stack
- [ ] **Grafana**: Port-forward Grafana, login with admin credentials, dashboards load.
- [ ] **Loki**: In Grafana Explore, query `{app="frontend"}` returns logs.
- [ ] **Tempo**: In Grafana Explore, search traces for `frontend` shows spans across services.
- [ ] **Mimir**: Grafana dashboards show metrics (CPU, memory, request counts).
- [ ] **Alloy**: Alloy pod logs confirm OTLP telemetry forwarding.

### Demo App
- [ ] **Frontend service**: Port-forward frontend, `curl http://localhost:3000/place-order` returns `200 OK`.
- [ ] **Backend Orders**: Requests to `/orders` succeed.
- [ ] **Backend Users**: Requests to `/users` succeed.
- [ ] **Trace propagation**: Tempo shows spans across frontend → orders → users.

### SLOs & Alerts
- [ ] **SLO definitions**: Sloth/Pyrra CRDs applied, Grafana shows error budgets.
- [ ] **Alertmanager**: Alerts visible in Grafana Alerting tab, routed to webhook receiver.
- [ ] **Inhibit rules**: Critical alerts suppress warnings as expected.

---

## 🧭 Quick Validation Commands

```bash
# Check all observability pods
kubectl get pods -n observability

# Generate traffic
kubectl port-forward svc/frontend -n observability 3000:3000
curl http://localhost:3000/place-order

# Verify traces
kubectl logs deploy/alloy -n observability | grep "exporter"
```

---

## 🧹 Teardown

When you are finished testing, follow these steps to cleanly remove the observability stack and cluster resources.

### Step 1 — Delete Argo CD Applications
Remove all child apps and the root app:

```bash
kubectl delete application --all -n argocd
```

This ensures workloads (Grafana, Loki, Tempo, Mimir, Alloy, Demo App, SLOs, Alertmanager) are removed.

---

### Step 2 — Delete Observability Namespace
Clean up the namespace and PVCs:

```bash
kubectl delete namespace observability
```

Verify PVCs are gone:

```bash
kubectl get pvc -A
```

---

### Step 3 — Remove Argo CD
Delete Argo CD installation:

```bash
kubectl delete namespace argocd
```

---

### Step 4 — Destroy Cluster
Use Terraform to destroy the K3D cluster and supporting infra:

```bash
cd infra/terraform
terraform destroy -auto-approve
```

---

### Step 5 — Verify Cleanup
- [ ] **No pods**: `kubectl get pods -A` shows no observability workloads.  
- [ ] **No PVCs**: `kubectl get pvc -A` shows none.  
- [ ] **Cluster removed**: `k3d cluster list` shows no clusters.  

---

## 🧭 Notes
- Always run `terraform destroy` last to ensure dependent resources (PVCs, namespaces) are cleaned up first.  
- If PVCs remain stuck, manually delete them with:
  ```bash
  kubectl delete pvc <name> -n observability
  ```
- For a complete reset, remove local Docker volumes created by K3D:
  ```bash
  docker volume ls | grep k3d | awk '{print $2}' | xargs docker volume rm
  ```

---

This teardown ensures you **reclaim disk and memory resources** cleanly, leaving your local environment ready for the next run.

---

## ⚡ Quickstart TL;DR

For fast reference, here’s the condensed 5‑step bootstrap flow:

1. **Provision cluster**  
   ```bash
   cd infra/terraform
   terraform init && terraform apply -auto-approve
   ```

2. **Verify Argo CD**  
   ```bash
   kubectl get pods -n argocd
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. **Sync root app**  
   ```bash
   argocd app sync root-app
   ```

4. **Generate traffic**  
   ```bash
   kubectl port-forward svc/frontend -n observability 3000:3000
   curl http://localhost:3000/place-order
   ```

5. **Observe in Grafana**  
   ```bash
   kubectl port-forward svc/grafana -n observability 3000:3000
   ```
   Open `http://localhost:3000` → Explore traces/logs/metrics, check dashboards, alerts, and SLOs.

---

This TL;DR gives you a **one‑page bootstrap recipe**: provision, verify, sync, generate traffic, and observe telemetry.

---

## ⚠️ Common Pitfalls

### Missing `.git` Suffix in repoURL
- **Symptom**: Argo CD fails to sync applications.
- **Cause**: `repoURL` missing `.git` suffix.
- **Fix**: Always use `https://github.com/SwamyVaditya/observability-platform.git`.

---

### Resource Limits Too High
- **Symptom**: Pods stuck in `Pending` or cluster OOM.
- **Cause**: Default Helm values request more CPU/memory than local cluster can provide.
- **Fix**: Use downsized values (100m CPU / 256Mi memory typical).

---

### PVCs Not Downsized
- **Symptom**: PVCs fail to bind or exceed local disk quota.
- **Cause**: Default storage requests too large.
- **Fix**: Ensure PVCs are downsized (Grafana, Loki, Mimir = 2Gi; Tempo = 1Gi).

---

### Forgetting Port-Forward
- **Symptom**: Cannot access Grafana, frontend, or Argo CD UI.
- **Cause**: Services not exposed externally.
- **Fix**: Use `kubectl port-forward` for Grafana, frontend, and Argo CD server.

---

### Skipping Argo CD Sync
- **Symptom**: Child apps not deployed.
- **Cause**: Root app applied but not synced.
- **Fix**: Run:
  ```bash
  argocd app sync root-app
  ```

---

### Grafana Password Not Retrieved
- **Symptom**: Cannot log in to Grafana.
- **Cause**: Default admin password not known.
- **Fix**: Retrieve from secret:
  ```bash
  kubectl get secret grafana -n observability -o jsonpath="{.data.admin-password}" | base64 -d
  ```

---

### Alloy Misconfiguration
- **Symptom**: No telemetry flowing to LGTM stack.
- **Cause**: OTLP exporter misconfigured.
- **Fix**: Verify demo-app services export to `http://alloy:4317`.

---

## 🧭 Key References
- **Argo CD repoURL pitfalls**
- **Resource downsizing**
- **PVC quota issues**
- **Port-forwarding services**
- **Grafana password retrieval**
- **Alloy OTLP exporter**

---

## 🎯 Success Criteria

Use this checklist to confirm the observability platform is fully operational:

### Cluster & GitOps
- ✅ **Cluster ready**: `kubectl get nodes` shows all nodes `Ready`.
- ✅ **Argo CD healthy**: All Argo CD pods `Running`, root app `Healthy` and `Synced`.
- ✅ **Child apps deployed**: Grafana, Loki, Tempo, Mimir, Alloy, Demo App, SLOs, Alertmanager visible in Argo CD UI.

### Demo App
- ✅ **Frontend reachable**: Port-forward frontend, `curl /place-order` returns `200 OK`.
- ✅ **Backend services functional**: Orders and Users endpoints respond successfully.
- ✅ **Trace propagation**: Tempo shows spans across frontend → orders → users.

### Observability Stack
- ✅ **Logs visible**: Grafana Explore → Loki shows structured logs from demo-app.
- ✅ **Traces visible**: Grafana Explore → Tempo shows distributed traces.
- ✅ **Metrics visible**: Grafana dashboards show CPU/memory/request metrics.
- ✅ **Dashboards functional**: Grafana dashboards load without errors.

### SLOs & Alerts
- ✅ **SLOs applied**: Sloth/Pyrra CRDs applied, Grafana shows error budgets.
- ✅ **Alerts firing**: Alertmanager routes alerts to webhook receiver, visible in Grafana Alerting tab.
- ✅ **Inhibit rules working**: Critical alerts suppress warnings as expected.

---

If all criteria above are met, the observability stack is **successfully bootstrapped** and ready for demonstration.

---

## 📈 Next Steps

Once the observability stack is successfully bootstrapped and validated, consider these extensions:

### Scaling & Retention
- **Increase PVC sizes**: Expand Grafana, Loki, Mimir, Tempo storage for longer retention.
- **Adjust retention policies**: Move from short demo defaults (7d logs, 3d traces) to production values (30–90d).
- **Resource tuning**: Increase CPU/memory requests for higher throughput.

### Dashboards & Visualization
- **Import Grafana dashboards**: Add service‑specific dashboards (frontend latency, backend error rates).
- **Create custom panels**: Visualize SLO error budgets, alert trends, and request distributions.

### Alerts & SLOs
- **Expand SLO coverage**: Add latency and availability objectives for all services.
- **Configure Alertmanager routes**: Send alerts to Slack, email, or PagerDuty.
- **Test inhibit rules**: Validate suppression of lower‑severity alerts.

### GitOps & CI/CD
- **Integrate CI/CD**: Automate manifest validation and Argo CD sync checks.
- **Add health checks**: Liveness/readiness probes for demo app services.
- **Enable progressive delivery**: Canary or blue‑green deployments for demo app.

### Production Hardening
- **Enable TLS**: Secure traffic with cert-manager.
- **Add NetworkPolicies**: Restrict pod‑to‑pod communication.
- **Configure RBAC**: Fine‑grained access control for observability namespaces.

---
