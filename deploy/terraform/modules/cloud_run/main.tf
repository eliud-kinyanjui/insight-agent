resource "google_cloud_run_service" "app" {
  name     = var.service_name
  project  = var.project_id
  location = var.region

  template {
    spec {
      service_account_name = var.service_account_email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repo_id}/${var.service_name}:${var.image_tag}"

        ports {
          container_port = var.container_port
          name           = "http1"
        }

        # Environment variables
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        # Resource requests and limits
        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
          requests = {
            cpu    = var.cpu_request
            memory = var.memory_request
          }
        }

        # Liveness probe
        liveness_probe {
          http_get {
            path = var.liveness_probe_path
            port = var.container_port
          }
          initial_delay_seconds = 30
          timeout_seconds       = 5
          period_seconds        = 10
        }

        # Startup probe
        startup_probe {
          http_get {
            path = var.startup_probe_path
            port = var.container_port
          }
          initial_delay_seconds = 0
          timeout_seconds       = 5
          failure_threshold     = 3
        }
      }

      # Timeout for requests
      timeout_seconds = var.timeout_seconds

      # Concurrency settings
      container_concurrency = var.container_concurrency

    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = var.max_instances
        "autoscaling.knative.dev/minScale" = var.min_instances
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

}

# Remove public access - no allUsers invoker
resource "google_cloud_run_service_iam_binding" "noauth" {
  service  = google_cloud_run_service.app.name
  location = var.region
  project  = var.project_id
  role     = "roles/run.invoker"
  members  = [] # Empty = no public access
}
