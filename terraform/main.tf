terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.gcp_account_key)
}

# Enable required GCP APIs
module "gcp_apis" {
  source     = "./modules/gcp_apis"
  project_id = var.project_id
}

# Artifact Registry
module "artifact_registry" {
  source        = "./modules/artifact_registry"
  project_id    = var.project_id
  region        = var.region
  repository_id = var.artifact_repo_id
  description   = var.artifact_repo_description
  depends_on    = [module.gcp_apis]
}

# IAM Module - manage IAM roles and permissions
module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
  depends_on = [module.gcp_apis]
}


# Cloud Run Module - deploy Cloud Run services
module "cloud_run" {
  source                 = "./modules/cloud_run"
  project_id             = var.project_id
  region                 = var.region
  service_name           = var.cloud_run_service_name
  artifact_repo_id       = var.artifact_repo_id
  image_tag              = var.image_tag
  service_account_email  = module.iam.runtime_service_account_email
  container_port         = var.container_port
  min_instances          = var.min_instances
  max_instances          = var.max_instances
  cpu_limit              = var.cpu_limit
  memory_limit           = var.memory_limit

  
  depends_on = [
    module.artifact_registry,
    module.iam,
  ]
}
