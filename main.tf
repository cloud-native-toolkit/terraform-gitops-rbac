locals {
  bin_dir = "${path.cwd}/bin"
  layer = "infrastructure"
  label = var.label != null && var.label != "" ? var.label : "${var.namespace}-rbac"
  namespace = var.cluster_scope ? "default" : var.namespace
  name = "rbac-${var.label}"
  yaml_dir = "${path.cwd}/.tmp/rbac-${local.label}"
  provision = length(var.rules) > 0
}

resource null_resource setup_binaries {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-binaries.sh"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource create_yaml {
  count = local.provision ? 1 : 0
  depends_on = [null_resource.setup_binaries]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${var.namespace}' '${var.service_account_name}' '${var.service_account_namespace}' '${local.label}' '${var.cluster_scope}'"

    environment = {
      RULES = yamlencode(var.rules)
    }
  }
}

resource null_resource igc_version {
  depends_on = [null_resource.setup_binaries]

  provisioner "local-exec" {
    command = "ls -l ${local.bin_dir}; $(command -v igc || command -v ${local.bin_dir}/igc) --version"
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml, null_resource.igc_version]

  provisioner "local-exec" {
    command = "$(command -v igc || command -v ${local.bin_dir}/igc) gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.serverName}' -l '${local.layer}'"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
