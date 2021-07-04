locals {
  layer = "infrastructure"
  config_project = var.config_projects[local.layer]
  application_branch = "main"
  label = var.label != null && var.label != "" ? var.label : "${var.namespace}-rbac"
  application_repo_path = "${var.application_paths[local.layer]}/namespace/${var.namespace}"
  namespace = var.cluster_scope ? "default" : var.namespace
}

resource null_resource setup_rbac {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-rbac.sh '${var.application_repo}' '${local.application_repo_path}' '${var.namespace}' '${var.service_account_name}' '${var.service_account_namespace}' '${local.label}' '${var.cluster_scope}'"

    environment = {
      TOKEN = var.application_token
      RULES = yamlencode(var.rules)
    }
  }
}

resource null_resource setup_argocd {
  depends_on = [null_resource.setup_rbac]
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-argocd.sh '${var.config_repo}' '${var.config_paths[local.layer]}' '${local.config_project}' '${var.application_repo}' '${local.application_repo_path}' '${var.namespace}' '${local.application_branch}'"

    environment = {
      TOKEN = var.config_token
    }
  }
}
