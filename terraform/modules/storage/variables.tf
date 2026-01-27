variable "project_id" {
  description = "The ID of the Google Cloud project."
  type        = string
}

variable "region" {
  description = "The Google Cloud region."
  type        = string
}

variable "bucket_name" {
  description = "gcs bucket name"
  type        = string
}

variable "deployer_service_account_email" {
  description = "Email of the Cloud Build/Terraform deployer service account"
  type        = string
}