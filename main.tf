/**
 * Usage:
 *
 * ```hcl
 *
 * module "vault_oidc_azure" {
 *   source            = "git::https://github.com/devops-adeel/terraform-vault-auth-azure.git?ref=v0.1.0"
 *   application_name  = "tdp"
 *   env               = "dev"
 *   service           = "web"
 *   identity_group_id = module.static_secrets.identity_group_id
 *   mount_accessor    = vault_auth_backend.default.accessor
 * }
 * ```
 */


locals {
  ad_group       = var.ad_group
  env            = var.env
  service        = var.service
  application    = var.application_name
  mount_accessor = var.mount_accessor
  backend_path   = "oidc"
}

resource "vault_jwt_auth_backend_role" "default" {
  backend               = local.backend_path
  role_name             = local.ad_group
  role_type             = local.backend_path
  user_claim            = "email"
  groups_claim          = "groups"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
  oidc_scopes           = ["https://graph.microsoft.com/.default"]
}

resource "vault_identity_group" "default" {
  name = local.ad_group
  type = "external"
  metadata = {
    env         = local.env
    service     = local.service
    application = local.application
  }
}

resource "vault_identity_group_alias" "default" {
  name           = local.ad_group
  mount_accessor = local.mount_accessor
  canonical_id   = vault_identity_group.default.id
}

data "vault_policy_document" "default" {
  rule {
    path         = "secret/+/{{identity.groups.ids.${vault_identity_group.default.id}.metadata.env}}-{{identity.groups.ids.${vault_identity_group.default.id}.metadata.service}}/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow read of static secret object named after metadata keys"
  }
  rule {
    path         = "auth/token/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "create child tokens"
  }
}

resource "vault_policy" "default" {
  name   = "${local.ad_group}-default-kv-store"
  policy = data.vault_policy_document.default.hcl
}


resource "vault_identity_group_policies" "default" {
  group_id  = vault_identity_group.default.id
  exclusive = false
  policies  = [vault_policy.default.name]
}
