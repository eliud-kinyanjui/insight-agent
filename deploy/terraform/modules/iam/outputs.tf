output "deployer_service_account_email" {
  description = "Email of the deployer service account"
  value       = google_service_account.cloudrun_deployer.email
}

output "runtime_service_account_email" {
  description = "Email of the runtime service account"
  value       = google_service_account.cloudrun_runtime.email
}