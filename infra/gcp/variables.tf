variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "region" {
  type        = string
  description = "GCP region (Always Free eligible preferred)"
}

variable "zone" {
  type        = string
  description = "GCP zone in the chosen region"
}

variable "ts_authkey" {
  type        = string
  description = "Tailscale auth key"
  sensitive   = true
}

variable "ts_hostname" {
  type        = string
  description = "Hostname for the Tailscale node"
  default     = "ts-router"
}

variable "ts_svc_hostname" {
  type        = string
  description = "Hostname for the service VM"
  default     = "service-host"
}
