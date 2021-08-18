locals {
  bin_dir  = module.setup_clis.bin_dir
  layer = "infrastructure"
  label = var.label != null && var.label != "" ? var.label : var.service_account_name
  namespace = var.cluster_scope ? "default" : var.namespace
  name = "${local.label}-rbac"
  yaml_dir = "${path.cwd}/.tmp/rbac-${local.label}"
  provision = length(var.rules) > 0
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  count = local.provision ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.namespace}' '${var.service_account_name}' '${var.service_account_namespace}' '${local.label}' '${var.cluster_scope}'"

    environment = {
      RULES = yamlencode(var.rules)
    }
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = yamlencode(nonsensitive(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
