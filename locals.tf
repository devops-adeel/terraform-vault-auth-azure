locals {
  oidc_url = format(
    "https://login.microsoftonline.com/%s/v2.0",
    data.azuread_client_config.default.tenant_id
  )
}
