locals {
  application_name = "terraform-vault-auth-oidc-azure-ad"
  role_id          = format("%s-%s", local.application_name, local.service)
  env              = "dev"
  service          = "db"
  application      = "oidc"
  mount_accessor   = data.vault_auth_backend.default.accessor
}

data "azuread_client_config" "default" {}

data "vault_auth_backend" "default" {
  path = "oidc"
}

resource "azuread_application" "default" {
  display_name = local.application_name
  owners       = [data.azuread_client_config.default.object_id]

  api {
    oauth2_permission_scope {
      admin_consent_description  = "Allow the HCP-Vault to validate AD user logging into Vault."
      admin_consent_display_name = "HCP Vault"
      enabled                    = true
      id                         = "00000003-0000-0000-c000-000000000000"
      type                       = "User"
      value                      = "GroupMember.Read.All"
    }
    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access AD on behalf of the signed-in user."
      admin_consent_display_name = "Access Impersonation"
      enabled                    = true
      id                         = "96183846-204b-4b43-82e1-5d2222eb4b9b"
      type                       = "User"
      user_consent_description   = "Allow the application to access example on your behalf."
      user_consent_display_name  = "Access example"
      value                      = "user_impersonation"
    }
  }
  web {
    redirect_uris = ["http://localhost:8250/oidc/callback"]

    implicit_grant {
      access_token_issuance_enabled = true
    }
  }
}

resource "azuread_service_principal" "default" {
  application_id               = azuread_application.default.application_id
  app_role_assignment_required = false
}

resource "vault_jwt_auth_backend_role" "default" {
  backend               = data.vault_auth_backend.default.path
  role_name             = "default"
  token_policies        = ["default"]
  user_claim            = "email"
  groups_claim          = "groups"
  role_type             = "oidc"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
  oidc_scopes           = ["https://graph.microsoft.com/.default"]
}

resource "vault_identity_group" "default" {
  name = local.role_id
  type = "external"
  metadata = {
    env         = local.env
    service     = local.service
    application = local.application
  }
}

resource "vault_identity_group_alias" "default" {
  name           = "aaaatest1"
  mount_accessor = local.mount_accessor
  canonical_id   = vault_identity_group.default.id
}
