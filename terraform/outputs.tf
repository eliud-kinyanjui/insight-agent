# Project Information
output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "zone" {
  description = "GCP zone"
  value       = var.zone
}

output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    project_id     = var.project_id
    region         = var.region
    service_name   = var.cloud_run_service_name
    image_tag      = var.image_tag
    
    # Cloud Run service details
    service_url    = try(module.cloud_run.service_url, "Not deployed")
    service_id     = try(module.cloud_run.service_id, "Not deployed")
    
    # Artifact Registry
    image_full_path = "${module.artifact_registry.repository_url}/${var.cloud_run_service_name}:${var.image_tag}"
    
    # Service Accounts
    deployer_sa    = try(module.iam.cloudrun_deployer_email, "Not created")
    runtime_sa     = try(module.iam.cloudrun_runtime_email, "Not created")
    
    # Storage
    state_bucket   = try(module.storage.bucket_name, "Not created")
    
    # Enabled APIs
    enabled_apis   = try(module.gcp_apis.enabled_services, [])
    
    deployment_time = timestamp()
  }
}