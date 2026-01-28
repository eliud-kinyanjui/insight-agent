# Service Account for Cloud Run deployment
resource "google_service_account" "cloudrun_deployer" {
  account_id   = "cloudrun-deployer"
  display_name = "Cloud Run Deployer Service Account"
  description  = "Service account for deploying Cloud Run applications"
  project      = var.project_id
}

# Service Account for Cloud Run runtime
resource "google_service_account" "cloudrun_runtime" {
  account_id   = "cloudrun-runtime"
  display_name = "Cloud Run Runtime Service Account"
  description  = "Service account used by Cloud Run services at runtime"
  project      = var.project_id
}


# IAM roles for deployer service account
resource "google_project_iam_member" "cloudrun_deployer_roles" {
  for_each = toset([
    "roles/run.admin",                      # Manage Cloud Run services
    "roles/iam.serviceAccountUser",         # Act as service accounts
    "roles/artifactregistry.repoAdmin",     # Manage Artifact Registry repositories
    "roles/logging.logWriter",              # Write logs
    "roles/storage.admin",                  # Manage GCS buckets/objects
    "roles/serviceusage.serviceUsageAdmin", # Enable/disable APIs (for terraform)
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudrun_deployer.email}"
}

# IAM roles for runtime service account (minimal permissions)
resource "google_project_iam_member" "cloudrun_runtime_roles" {
  for_each = toset([
    "roles/logging.logWriter",       # Write logs
    "roles/cloudtrace.agent",        # Send traces
    "roles/monitoring.metricWriter", # Write metrics
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudrun_runtime.email}"
}

# Cloud Build service account needs to impersonate deployer
resource "google_project_iam_member" "cloudbuild_impersonate_deployer" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudrun_deployer.email}"
}