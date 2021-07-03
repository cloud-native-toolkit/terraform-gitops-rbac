
variable "config_repo" {
  type        = string
  description = "The repo that contains the argocd configuration"
}

variable "config_token" {
  type        = string
  description = "The token for the config repo"
}

variable "config_paths" {
  description = "The paths in the config repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
}

variable "config_projects" {
  description = "The ArgoCD projects in the config repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
}

variable "application_repo" {
  type        = string
  description = "The repo that contains the application configuration"
}

variable "application_token" {
  type        = string
  description = "The token for the application repo"
}

variable "application_paths" {
  description = "The paths in the application repo"
  type        = object({
    infrastructure = string
    services       = string
    applications   = string
  })
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
    verbs     = list(string)
  }))
  description = "The rules that should be created in the role"
}
