output "bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = google_storage_bucket.terraform_state.name
}

output "artifacts_bucket_name" {
  description = "Name of the build artifacts bucket"
  value       = google_storage_bucket.build_artifacts.name
}