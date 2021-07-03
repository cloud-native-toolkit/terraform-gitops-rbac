locals {
  layer = "infrastructure"
  config_project = var.config_projects[local.layer]
  application_branch = "main"
  label = var.label != null && var.label != "" ? var.label : "${var.namespace}-rbac"
}

resource null_resource setup_rbac {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-namespace.sh '${var.application_repo}' '${var.application_paths[local.layer]}' '${var.namespace}' '${var.service_account_name}' '${var.service_account_namespace}' '${local.label}'"

    environment = {
      TOKEN = var.application_token
      RULES = yamlencode(var.rules)
    }
  }
}

resource null_resource setup_argocd {
  depends_on = [null_resource.setup_rbac]
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-argocd.sh '${var.config_repo}' '${var.config_paths[local.layer]}' '${local.config_project}' '${var.application_repo}' '${var.application_paths[local.layer]}/rbac/${var.namespace}' '${var.namespace}' '${local.application_branch}'"

    environment = {
      TOKEN = var.config_token
    }
  }
}
