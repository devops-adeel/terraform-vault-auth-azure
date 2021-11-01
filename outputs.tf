output "auth_backend_accessor" {
  description = "Accessor ID for OIDC Auth Backend"
  value       = vault_jwt_auth_backend.default.accessor
}
