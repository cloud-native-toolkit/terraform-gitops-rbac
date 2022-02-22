output "service_account_name" {
  value = var.service_account_name
  depends_on = [gitops_module.module]
}

output "service_account_namespace" {
  value = var.service_account_namespace
  depends_on = [gitops_module.module]
}
