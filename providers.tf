terraform {
  required_version = ">=1.3.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.47.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.9.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "7010a62d-1c01-44b2-b84e-9e38000f3f54"
}

provider "helm" {
  kubernetes {
    config_path = ".kube/config"
  }

  # localhost registry with password protection
  /*registry {
    url = "oci://localhost:5000"
    username = "username"
    password = "password"
  }

  # private registry
  registry {
    url = "oci://private.registry"
    username = "username"
    password = "password"
  }*/
}