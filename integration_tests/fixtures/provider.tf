terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 1.5.0"
    }
  }
  backend "remote" {
    organization = "hc-implementation-services"

    workspaces {
      name = "terraform-vault-auth-azure"
    }
  }
}

variable "approle_id" {}
variable "approle_secret" {}

provider "vault" {
  auth_login {
    namespace = "admin/terraform-vault-auth-azure"
    path      = "auth/approle/login"

    parameters = {
      role_id   = var.approle_id
      secret_id = var.approle_secret
    }
  }
}

provider "azuread" {}
