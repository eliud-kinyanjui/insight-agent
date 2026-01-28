output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_service.app.status[0].url
}

output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_service.app.name
}

output "service_id" {
  description = "Cloud Run service ID"
  value       = google_cloud_run_service.app.id
}

output "latest_revision_name" {
  description = "Latest revision name"
  value       = google_cloud_run_service.app.status[0].latest_ready_revision_name
}

output "ingress_settings" {
  description = "Ingress settings (ALLOW_ALL or ALLOW_INTERNAL_ONLY)"
  value       = "ALLOW_INTERNAL_ONLY"
}