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

  clis = ["jq", "yq", "igc"]
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

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]
  count = local.provision ? 1 : 0

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}
