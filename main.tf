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
  role_id        = format("%s-%s", var.application_name, var.service)
  group_id       = var.identity_group_id
  env            = var.env
  service        = var.service
  application    = var.application_name
  mount_accessor = var.mount_accessor
  backend_path   = "oidc"
}

resource "vault_jwt_auth_backend_role" "default" {
  backend   = local.backend_path
  role_name = local.role_id
  role_type             = local.backend_path
  user_claim            = "email"
  groups_claim          = "groups"
  allowed_redirect_uris = ["http://localhost:8200/ui/vault/auth/oidc/oidc/callback"]
  oidc_scopes           = "https://graph.microsoft.com/.default"
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
  name = "OIDC_AD_Group_Slug"
  mount_accessor = local.mount_accessor
  canonical_id   = vault_identity_group.default.id
}

resource "vault_identity_group_member_group_ids" "default" {
  member_entity_ids = [vault_identity_group.default.id]
  exclusive         = false
  group_id          = local.group_id
}
