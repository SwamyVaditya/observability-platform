# Architecture — Observability Platform

This document illustrates the architecture of the observability stack and how telemetry flows across services.

---

## 📊 High-Level Diagram

```ascii
                ┌───────────────┐
                │   Frontend    │ (Node.js)
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │ Backend Orders│ (FastAPI)
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │ Backend Users │ (FastAPI)
                └───────┬───────┘
                        │
                        ▼
                ┌─────────────────────┐
                │ Grafana Alloy       │
                │ (Unified Collector) │
                └───────┬─────────────┘
   ┌────────────────────┼────────────────────┐
   ▼                    ▼                    ▼
┌───────┐          ┌────────┐           ┌────────┐
│ Loki  │          │ Tempo  │           │ Mimir  │
│ Logs  │          │ Traces │           │ Metrics│
└───┬───┘          └───┬────┘           └───┬────┘
    │                  │                    │
    └──────────┬───────┴──────────────┬─────┘
               ▼                      ▼
         ┌───────────┐          ┌──────────────┐
         │ Grafana   │          │ Alertmanager │
         │ Dashboards│          │ Alerts       │
         └───────────┘          └──────────────┘
```

---

## 🔄 Sequence Diagram — Request Flow

```mermaid
sequenceDiagram
    participant User
    participant Frontend as Frontend (Node.js)
    participant Orders as Backend Orders (FastAPI)
    participant Users as Backend Users (FastAPI)
    participant Alloy as Grafana Alloy Collector
    participant Tempo as Tempo (Traces)
    participant Loki as Loki (Logs)
    participant Mimir as Mimir (Metrics)

    User->>Frontend: HTTP GET /place-order
    Frontend->>Orders: HTTP POST /orders
    Orders->>Users: HTTP GET /users
    Users-->>Orders: Response (user data)
    Orders-->>Frontend: Response (order confirmation)
    Frontend-->>User: Response (200 OK)

    note over Frontend,Orders: OpenTelemetry spans/logs/metrics emitted
    note over Orders,Users: Trace context propagated

    Frontend->>Alloy: OTLP telemetry export
    Orders->>Alloy: OTLP telemetry export
    Users->>Alloy: OTLP telemetry export

    Alloy->>Tempo: Forward traces
    Alloy->>Loki: Forward logs
    Alloy->>Mimir: Forward metrics
```

---

## 🔀 Data Flow Diagram — Telemetry Pipeline

```mermaid
flowchart TD
    subgraph DemoApp["Demo App Microservices"]
        FE["Frontend (Node.js)"]
        BO["Backend Orders (FastAPI)"]
        BU["Backend Users (FastAPI)"]
    end

    subgraph Alloy["Grafana Alloy Collector"]
        OTLP["OTLP Receiver"]
        PromScrape["Prometheus Scraper"]
        LokiClient["Loki Client"]
        TempoClient["Tempo Client"]
        MimirClient["Mimir Remote Write"]
    end

    subgraph LGTM["LGTM Stack"]
        Loki["Loki — Logs"]
        Tempo["Tempo — Traces"]
        Mimir["Mimir — Metrics"]
    end

    Grafana["Grafana Dashboards"]
    Alertmanager["Alertmanager"]
    SLOs["Sloth/Pyrra SLOs"]

    FE --> OTLP
    BO --> OTLP
    BU --> OTLP

    OTLP --> LokiClient --> Loki
    OTLP --> TempoClient --> Tempo
    OTLP --> MimirClient --> Mimir
    PromScrape --> Mimir

    Loki --> Grafana
    Tempo --> Grafana
    Mimir --> Grafana

    Mimir --> SLOs --> Alertmanager
    Alertmanager --> Grafana
```

---

## 🔑 Key Components

- **Demo App**: Node.js frontend + Python FastAPI backends emit telemetry.  
- **Grafana Alloy**: Unified collector for metrics, logs, and traces.  
- **Loki**: Centralized log storage and querying.  
- **Tempo**: Distributed tracing backend.  
- **Mimir**: Scalable metrics storage and query engine.  
- **Grafana**: Dashboards, Explore, and visualization.  
- **Alertmanager**: Alert routing and inhibition.  
- **Sloth/Pyrra**: SLO definitions and error budget tracking.  

---

## ⚖️ Resource Constraints

- PVCs downsized (Grafana, Loki, Mimir = 2Gi; Tempo = 1Gi)  
- Resource requests/limits reduced (100m CPU / 256Mi memory typical)  
- Retention policies shortened (logs 7d, traces 3d)  

---

## 🧭 Why This Matters

This architecture demonstrates:
- **GitOps orchestration** with Argo CD App‑of‑Apps.  
- **End‑to‑end observability** across metrics, logs, and traces.  
- **Realistic demo app** with service boundaries and telemetry propagation.  
- **SLO‑driven alerts** integrated into the platform.  

---
