terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 2.23.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.2.1"
    }
  }
}
