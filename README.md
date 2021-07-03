# Gitops RBAC

Module to configure role and role binding RBAC in a gitops repo.

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v13

### Terraform providers

- IBM Cloud provider >= 1.5.3

## Module dependencies

This module makes use of the output from other modules:

- Gitops - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git
- Argocd - github.com/cloud-native-toolkit/terraform-tools-openshift-gitops.git

## Example usage

```hcl-terraform
module "gitops_rbac" {
  source = "github.com/ibm-garage-cloud/terraform-gitops-rbac.git"

  config_repo = module.gitops.config_repo
  config_token = module.gitops.config_token
  config_paths = module.gitops.config_paths
  config_projects = module.gitops.config_projects
  application_repo = module.gitops.application_repo
  application_token = module.gitops.application_token
  application_paths = module.gitops.application_paths
  service_account_namespace = "openshift-gitops"
  service_account_name      = "argocd-cluster-argocd-application-controller"
  namespace = module.gitops_namespace.name
}
```
