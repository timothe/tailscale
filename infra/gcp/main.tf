terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = { source = "hashicorp/google", version = ">= 5.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "default" {
  name    = "default"
  region  = var.region
  project = var.project_id
}

resource "google_compute_instance" "ts_router" {
  name           = var.ts_hostname
  machine_type   = "e2-micro"
  zone           = var.zone
  can_ip_forward = true
  tags           = ["ts-router"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork  = data.google_compute_subnetwork.default.self_link
    access_config {}
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  metadata_startup_script = templatefile("${path.module}/scripts/startup.sh.tftpl", {
    ts_authkey = var.ts_authkey
    vpc_cidr   = data.google_compute_subnetwork.default.ip_cidr_range
    hostname   = var.ts_hostname
  })
}

output "instance_name"        { value = google_compute_instance.ts_router.name }
output "instance_external_ip" { value = google_compute_instance.ts_router.network_interface[0].access_config[0].nat_ip }
output "vpc_cidr"             { value = data.google_compute_subnetwork.default.ip_cidr_range }
