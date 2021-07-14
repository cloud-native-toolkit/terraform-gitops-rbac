output "service_account_name" {
  value = var.service_account_name
  depends_on = [null_resource.setup_gitops]
}

output "service_account_namespace" {
  value = var.service_account_namespace
  depends_on = [null_resource.setup_gitops]
}
