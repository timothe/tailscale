output "ssh_hint" {
  value = "Use Tailscale SSH: ssh tsadmin@${google_compute_instance.ts_router.name}"
}
