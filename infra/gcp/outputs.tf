output "ssh_hint" {
  value = "Use Tailscale SSH: ssh tsadmin@${google_compute_instance.ts_router.name}"
}
output "service_vm_internal_ip" {
  value = google_compute_instance.svc_vm.network_interface[0].network_ip
}
output "service_curl_hint" {
  value = "curl http://${google_compute_instance.svc_vm.network_interface[0].network_ip}:8080/"
}
