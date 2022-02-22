
variable "gitops_config" {
  type        = object({
    boostrap = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
    })
    infrastructure = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    services = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
    applications = object({
      argocd-config = object({
        project = string
        repo = string
        url = string
        path = string
      })
      payload = object({
        repo = string
        url = string
        path = string
      })
    })
  })
  description = "Config information regarding the gitops repo structure"
}

variable "git_credentials" {
  type = list(object({
    repo = string
    url = string
    username = string
    token = string
  }))
  description = "The credentials for the gitops repo(s)"
}

variable "service_account_namespace" {
  description = "The namespace where the service account can be found"
  type        = string
}

variable "service_account_name" {
  description = "The name of the service account that will be bound to the role"
  type        = string
}

variable "namespace" {
  type        = string
  description = "The namespace where the role should be provisioned"
  default     = ""
}

variable "label" {
  type        = string
  description = "The label used in the role and role-binding names"
  default     = ""
}

variable "rules" {
  type        = list(object({
    apiGroups = list(string)
    resources = list(string)
    resourceNames = optional(list(string))
    verbs     = list(string)
  }))
  description = "The rules that should be created in the role"
}

variable "roles" {
  type        = list(object({
    name      = string
  }))
  description = "List of existing roles or cluster roles for which a role binding should be created to this service account "
  default     = []
}

variable "cluster_scope" {
  type        = bool
  description = "Flag indicating that cluster scope RBAC should be created (ClusterRole and ClusterRoleBinding)"
  default     = false
}

variable "server_name" {
  type        = string
  description = "The cluster where the application will be provisioned"
  default     = "default"
}
