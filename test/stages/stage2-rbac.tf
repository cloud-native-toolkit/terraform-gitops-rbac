module "gitops_rbac" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  service_account_namespace = "openshift-gitops"
  service_account_name      = "argocd-cluster-argocd-application-controller"
  namespace = var.namespace
  rules = [{
      apiGroups = ["*"]
      resources = ["*"]
      verbs     = ["*"]
    }, {
    apiGroups = ["security.openshift.io"]
    resources = ["securitycontextconstraints"]
    resourceNames = ["turbonomic-t8c-operator-anyuid"]
    verbs = ["use"]
  }]
  roles = [{name = "edit"}]
  server_name = module.gitops.server_name
}
