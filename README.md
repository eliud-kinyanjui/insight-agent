# Insight Agent - PawaIT Assessment

A cloud-native FastAPI service that analyzes customer feedback and provides text insights. This project demonstrates enterprise-grade deployment practices on Google Cloud Platform.

Repo Link: [https://github.com/eliud-kinyanjui/insight-agent](https://github.com/eliud-kinyanjui/insight-agent)

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


### 3. CI/CD Pipeline Architecture

**9-Step Automated Pipeline** (defined in `cloudbuild.yaml`):

1. **Lint Python Code**: flake8, black, isort, pylint
   - Catches code style issues early
   - Enforces consistent formatting across team

2. **Run Unit Tests**: pytest with coverage
   - Tests collected in Cloud Build artifacts
   - Coverage reports ensure code quality

3. **Terraform Validation**: fmt check + validate
   - Infrastructure code syntax checking
   - Prevents invalid Terraform from merging

4. **Build Docker Image**: Multi-tag strategy
   - Tag by short commit SHA (e.g., `abc12345`)
   - Tag as "latest" for convenience
   - Enables quick rollback to previous versions

5. **Push to Artifact Registry**: Two pushes for redundancy
   - Images stored in Google's managed private registry
   - Regional endpoint for lower latency

6. **Security Scanning**: Trivy vulnerability scan
   - Detects known CVEs in base image and dependencies
   - JSON report stored for audit trail
   - Fails on HIGH/CRITICAL vulnerabilities (configurable)

7. **Terraform Plan & Apply**: Infrastructure deployment
   - Cloud Build impersonates Terraform SA
   - Plan shown before apply (in logs)
   - Auto-approve enabled for CI/CD trust

8. **Deployment Verification**: Output summary
   - Service endpoint, region, and image tag logged
   - Enables quick validation of deployment

9. **Artifact Storage**: Test and scan results
   - Stored in Cloud Storage for historical analysis
   - Integrated with Cloud Build UI for visibility

**Trigger Strategy**:
- Pipeline triggered on every commit to main branch
- Manual trigger option for other branches/hotfixes
- Supports canary deployments via image tag override


## Setup and Deployment Instructions

### Prerequisites
Before starting, ensure you have:
- **GCP Project** with billing enabled
- **gcloud CLI** installed and authenticated
- **Terraform** >= 1.0
- **Docker** installed (for local testing)
- **Git** configured with SSH keys (for repo access)
- Appropriate IAM roles in your GCP project:
  - `roles/iam.securityAdmin` (to create service accounts)
  - `roles/container.admin` (for Cloud Run)
  - `roles/artifactregistry.admin` (for Artifact Registry)
  - `roles/storage.admin` (for Terraform state bucket)
  - `roles/cloudbuild.builds.editor` (for Cloud Build)

### Step 1: Clone the Repository

```bash
git clone https://github.com/eliud-kinyanjui/insight-agent
cd insight-agent
```

### Step 2: Set Up GCP Credentials (Local Development)

Create a service account with necessary permissions:

```bash
# Set project
PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID

# Create service account for Terraform
gcloud iam service-accounts create insight-agent-terraform \
  --display-name="Insight Agent Terraform Deployer"

# Grant necessary roles (adjust as needed)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:insight-agent-terraform@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/cloudrun.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:insight-agent-terraform@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/artifactregistry.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:insight-agent-terraform@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountUser

# Create and download key
gcloud iam service-accounts keys create terraform_account_key.json \
  --iam-account=insight-agent-terraform@$PROJECT_ID.iam.gserviceaccount.com
```

**Store key securely** (already in `.gitignore`):

### Step 3: Configure Terraform Variables

Create or update `terraform/terraform.tfvars`:

### Step 4: Initialize and Deploy Infrastructure

**Local Terraform (One-time Setup)**:

```bash
cd terraform

# Initialize Terraform (downloads provider plugins, creates .terraform/)
terraform init

# Validate configuration
terraform validate

# Show what will be created
terraform plan

# Create all resources (Artifact Registry, Cloud Run service, IAM roles, etc.)
terraform apply

# Note the outputs (Cloud Run URL, etc.)
terraform output
```

### Step 5: Set Up Cloud Build for CI/CD

```bash
# Create Cloud Build service account
gcloud iam service-accounts create cloud-build-deployer \
  --display-name="Cloud Build Deployment Account"

# Grant necessary permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:cloud-build-deployer@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/artifactregistry.writer

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:cloud-build-deployer@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountUser

# Allow Cloud Build to impersonate Terraform SA
gcloud iam service-accounts add-iam-policy-binding \
  insight-agent-terraform@$PROJECT_ID.iam.gserviceaccount.com \
  --member=serviceAccount:cloud-build-deployer@$PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountUser

# Connect Cloud Build to your Git repository
# This is done via Cloud Console: Cloud Build > Triggers > Create Trigger
# Or via gcloud:
gcloud builds connect --repository-name=insight-agent --repository-owner=your-org
```

### Step 6: Test the Deployment Locally

**Build and run locally**:

```bash
# Build Docker image
docker build -t insight-agent:test .

# Run container
docker run -p 8080:8080 insight-agent:test

# In another terminal, test the API
curl -X POST http://localhost:8080/analyze \
  -H "Content-Type: application/json" \
  -d '{"text":"I love cloud engineering!"}'

# Check health endpoint
curl http://localhost:8080/health
```

### Step 7: Run Tests

The project includes a comprehensive test suite with 94% code coverage.

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run all tests
pytest tests/ -v

# Run with coverage report
pytest tests/ --cov=. --cov-report=term-missing

# Generate HTML coverage report
pytest tests/ --cov=. --cov-report=html

# Run specific test class
pytest tests/test_main.py::TestHealthEndpoint -v
```

**Test Coverage**:
- ✅ Health check endpoint
- ✅ Text analysis with various inputs (empty strings, unicode, special characters)
- ✅ Validation error handling
- ✅ Application metadata and API documentation

For detailed information about tests, see [tests/README.md](tests/README.md).

### Step 8: Deploy to Cloud Run (Manual Verification)

```bash
# Build and push manually (if not using Cloud Build)
gcloud builds submit --config cloudbuild.yaml

# Or deploy specific image
gcloud run deploy insight-agent \
  --image=${REGION}-docker.pkg.dev/${PROJECT_ID}/insight-agent/insight-agent:latest \
  --platform=managed \
  --region=africa-south1 \
  --service-account=insight-agent-runtime@${PROJECT_ID}.iam.gserviceaccount.com
```

### Step 9: Verify Deployment

```bash
# Get the service URL
gcloud run services describe insight-agent --platform=managed --region=africa-south1

# Test the deployed service
SERVICE_URL=$(gcloud run services describe insight-agent \
  --platform=managed --region=africa-south1 --format='value(status.url)')

curl -X POST $SERVICE_URL/analyze \
  -H "Content-Type: application/json" \
  -d '{"text":"Test feedback"}'

### Troubleshooting Setup Issues

| Issue | Solution |
|-------|----------|
| "Permission denied" errors | Verify your service account has required roles in IAM |
| Terraform state lock | Delete stuck locks: `terraform force-unlock <ID>` |
| Cloud Build fails to push | Check Artifact Registry permissions and repo exists |
| Cloud Run can't pull image | Verify service account has `artifactregistry.reader` role |
| Health check fails | Check container logs: `gcloud run logs read insight-agent` |


## Logging & Monitoring
All application logs are automatically captured by Cloud Run and sent to Cloud Logging:

**Log Collection**:
- FastAPI framework logs (requests, errors)
- stdout/stderr from the application
- Structured logs via Python logging module (recommended for production)

### Monitoring and Metrics
#### Built-in Cloud Run Metrics
Cloud Run automatically exposes metrics in Cloud Monitoring

### Health Checks
The application includes a dedicated health check endpoint (`/health`) that Cloud Run uses.