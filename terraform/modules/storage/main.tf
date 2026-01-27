resource "google_storage_bucket" "terraform_state" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "cloudbuild_state_access" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.deployer_service_account_email}"
}

# Build artifacts bucket
resource "google_storage_bucket" "build_artifacts" {
  name          = var.artifacts_bucket_name
  project       = var.project_id
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "cloudbuild_artifacts_access" {
  bucket = google_storage_bucket.build_artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.deployer_service_account_email}"
}