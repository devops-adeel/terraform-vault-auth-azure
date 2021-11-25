terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.10.1"
    }
  }
}
