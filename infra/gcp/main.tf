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

resource "google_compute_firewall" "allow_svc_8080" {
  name    = "allow-svc-8080"
  network = data.google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [data.google_compute_subnetwork.default.ip_cidr_range]
  target_tags   = ["svc-http"]
}

resource "google_compute_instance" "svc_vm" {
  name         = var.ts_svc_hostname
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["svc-http"]

  boot_disk {
    initialize_params { image = "debian-cloud/debian-12" }
  }

  network_interface {
    network    = data.google_compute_network.default.self_link
    subnetwork = data.google_compute_subnetwork.default.self_link
  }

  metadata_startup_script = templatefile("${path.module}/scripts/startup-service.sh.tftpl", {})
}

output "instance_name"        { value = google_compute_instance.ts_router.name }
output "instance_external_ip" { value = google_compute_instance.ts_router.network_interface[0].access_config[0].nat_ip }
output "vpc_cidr"             { value = data.google_compute_subnetwork.default.ip_cidr_range }
