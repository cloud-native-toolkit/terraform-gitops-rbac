locals {
  bin_dir  = module.setup_clis.bin_dir
  layer = "infrastructure"
  label = var.label != null && var.label != "" ? var.label : var.service_account_name
  namespace = var.cluster_scope ? "default" : var.namespace
  name = "${local.label}-rbac"
  yaml_dir = "${path.cwd}/.tmp/rbac-${local.label}"
  type = "base"
  provision = length(var.rules) > 0
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["jq", "yq"]
}

resource null_resource print_rules_length {
  provisioner "local-exec" {
    command = "echo 'Rule count: ${length(var.rules)}'"
  }
}

resource null_resource create_yaml {
  count = local.provision ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.namespace}' '${var.service_account_name}' '${var.service_account_namespace}' '${local.label}' '${var.cluster_scope}'"

    environment = {
      BIN_DIR = module.setup_clis.bin_dir
      RULES = yamlencode(var.rules)
      ROLES = jsonencode(var.roles)
    }
  }
}

resource gitops_module module {
  depends_on = [null_resource.create_yaml]
  count = local.provision ? 1 : 0

  name = local.name
  namespace = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}
