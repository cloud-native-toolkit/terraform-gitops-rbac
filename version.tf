terraform {
  required_version = ">= 0.15.0"

  experiments = [module_variable_optional_attrs]

  required_providers {
    gitops = {
      source = "cloud-native-toolkit/gitops"
      version = ">= 0.1.7"
    }
  }
}
