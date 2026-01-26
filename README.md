# Insight Agent - PawaIT Assessment

A cloud-native FastAPI service that analyzes customer feedback and provides text insights. This project demonstrates enterprise-grade deployment practices on Google Cloud Platform.

## Architecture Overview

The Insight Agent is built on a modern, scalable cloud-native architecture leveraging Google Cloud Platform services for reliability, security, and automated deployment.

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   [Developer]                                   |
|                    ↓                                            |
|                (Git Push)                                       |
|                    ↓                                            |
|                [GitHub Repo]                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                         Cloud Build                             │
│                    (CI/CD Pipeline)                             │
│  ┌──────────────┬──────────┬──────────┬────────────────────┐    │
│  │ Lint & Test  │  Build   │  Scan    │  Deploy (Terraform)     │
│  │   (Python)   │ (Docker) │ (Trivy)  │                    │    │
│  └──────────────┴──────────┴──────────┴────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│              Artifact Registry (Private Docker)                 │
│                    insight-agent repo                           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Cloud Run                                   │
│                 (Serverless Container)                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Insight Agent FastAPI Service                          │   │
│  │  • /analyze (POST) - Analyze customer feedback          │   │
│  │  • /health (GET)  - Health check endpoint               │   │
│  └─────────────────────────────────────────────────────────┘   │
│         (Runs with dedicated service account)                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│         Cloud Logging & Cloud Monitoring                        │
│  • Container logs → Cloud Logging                               │
│  • Metrics → Cloud Monitoring                                   │
│  • Alerts & dashboards for service health                       │
└─────────────────────────────────────────────────────────────────┘
```

### GCP Services Used

- **Cloud Build**: Automated CI/CD pipeline for building, testing, and deploying
- **Artifact Registry**: Secure, private container image repository
- **Cloud Run**: Serverless container execution platform
- **Cloud Logging**: Centralized logging for all application logs
- **Cloud Monitoring**: Metrics collection and alerting
- **IAM**: Fine-grained access control with dedicated service accounts
- **Terraform**: Infrastructure-as-Code for reproducible deployments

---

## Design Decisions

### 1. Why Cloud Run?

**Decision**: Deploy on Cloud Run instead of Compute Engine, GKE, or App Engine

**Rationale**:
- **Serverless**: No infrastructure management - automatic scaling from 0 to N instances
- **Cost-efficient**: Pay only for request processing time, not idle resources
- **Containerization**: Use standard Docker containers with no vendor lock-in constraints
- **Quick deployment**: ~1 minute deployments vs. longer provisioning times
- **Perfect fit**: The Insight Agent is stateless and request-driven, ideal for serverless
- **Automatic updates**: Cloud Run maintains the underlying infrastructure

**Trade-offs Considered**:
- Compute Engine: More control but requires manual scaling, patching, and management
- GKE: Powerful but adds complexity for a simple microservice
- App Engine: Limited language support and flexibility compared to Cloud Run

### 2. Security Architecture

**Multi-layered Security Approach**:

#### Service Accounts & IAM
- **Principle of Least Privilege**: Separate service accounts for:
  - **Cloud Run Runtime SA**: Only permissions to pull container images
  - **Terraform Deployer SA**: Deploy and manage infrastructure
  - **Build SA**: Push images to Artifact Registry, trigger deployments
- Each SA has minimal required permissions scoped to specific resources

#### Container Security
- **Non-root user**: Application runs as `appuser` (UID 1000) in the container
- **Read-only filesystem**: Minimizes attack surface
- **Artifact Registry**: Private registry - images stored securely, not in public Docker Hub
- **Image scanning**: Trivy scans all built images for HIGH and CRITICAL vulnerabilities

#### Deployment Security
- **Terraform impersonation**: Cloud Build impersonates a specific SA with deployment rights
- **Image tagging**: Deployments use specific SHA tags, not "latest", for reproducibility
- **Audit logging**: All IAM changes and deployments logged in Cloud Audit Logs