locals {
  layer = "infrastructure"
  layer_config = var.gitops_config[local.layer]
  application_branch = "main"
  label = var.label != null && var.label != "" ? var.label : "${var.namespace}-rbac"
  namespace = var.cluster_scope ? "default" : var.namespace
  yaml_dir = "${path.cwd}/.tmp/rbac-${local.label}"
}

resource null_resource setup_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.namespace}' '${var.service_account_name}' '${var.service_account_namespace}' '${local.label}' '${var.cluster_scope}'"

    environment = {
      RULES = yamlencode(var.rules)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.setup_yaml]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-gitops.sh 'namespace-${var.namespace}' '${local.yaml_dir}' 'namespace/${var.namespace}' '${local.application_branch}' '${var.namespace}'"

    environment = {
      GIT_CREDENTIALS = jsonencode(var.git_credentials)
      GITOPS_CONFIG = jsonencode(local.layer_config)
    }
  }
}