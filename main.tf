data "azuread_client_config" "default" {}

data "azuread_application" "default" {
  display_name = var.application_name
}

resource "time_rotating" "default" {
  rotation_days = 7
}

resource "azuread_application_password" "default" {
  display_name          = var.application_name
  application_object_id = data.azuread_application.default.object_id
  end_date_relative     = "17250h"
  keepers = {
    rotation = time_rotating.default.id
  }
}

resource "time_static" "default" {
  triggers = {
    client_secret = azuread_application_password.default.value
  }
}

resource "vault_jwt_auth_backend" "default" {
  description        = "Vault OIDC Auth Method"
  path               = "oidc"
  type               = "oidc"
  default_role       = var.application_name
  provider_config    = { provider = "azure" }
  oidc_discovery_url = local.oidc_url
  oidc_client_id     = data.azuread_application.default.application_id
  oidc_client_secret = time_static.default.triggers.client_secret
  tune {
    default_lease_ttl = "768h"
    max_lease_ttl     = "768h"
    token_type        = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "default" {
  backend               = vault_jwt_auth_backend.default.path
  role_type             = vault_jwt_auth_backend.default.path
  role_name             = var.application_name
  oidc_scopes           = ["profile", "https://graph.microsoft.com/.default"]
  allowed_redirect_uris = element(data.azuread_application.default.web[*].redirect_uris, 0)
  user_claim            = "email"
  groups_claim          = "groups"
}
