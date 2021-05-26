locals {
  application_name = "terraform-vault-auth-oidc-azure-ad"
  role_id          = format("%s-%s", local.application_name, local.service)
  env              = "dev"
  service          = "db"
  application      = "oidc"
  ad_group         = "aaaatest1"
  mount_accessor   = data.vault_auth_backend.default.accessor
}

data "vault_auth_backend" "default" {
  path = "oidc"
}

module "default" {
  source           = "./module"
  ad_group         = local.ad_group
  application_name = local.application_name
  env              = local.env
  service          = local.service
  mount_accessor   = local.mount_accessor
}
