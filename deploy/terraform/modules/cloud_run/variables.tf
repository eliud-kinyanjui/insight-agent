variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Cloud Run region"
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "insight-agent"
}

variable "artifact_repo_id" {
  description = "Artifact Registry repository ID"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag (e.g., commit SHA or 'latest')"
  type        = string
  default     = "latest"
}

variable "service_account_email" {
  description = "Service account email for Cloud Run runtime"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "1"
}

variable "memory_limit" {
  description = "Memory limit for the container (e.g., 512Mi, 1Gi)"
  type        = string
  default     = "512Mi"
}

variable "cpu_request" {
  description = "CPU request for the container"
  type        = string
  default     = "0.5"
}

variable "memory_request" {
  description = "Memory request for the container"
  type        = string
  default     = "256Mi"
}

variable "timeout_seconds" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300
}

variable "container_concurrency" {
  description = "Maximum concurrent requests per container"
  type        = number
  default     = 80
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 100
}

variable "liveness_probe_path" {
  description = "HTTP path for liveness probe"
  type        = string
  default     = "/health"
}

variable "startup_probe_path" {
  description = "HTTP path for startup probe"
  type        = string
  default     = "/health"
}