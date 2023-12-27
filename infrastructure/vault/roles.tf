resource "vault_policy" "policies" {
  for_each = var.apps
  name     = each.key

  policy = <<EOT
%{for path in each.value.secrets}
path "${var.kvv2_path}/data/${path}" {
  capabilities = ["read"]
}
%{endfor}
EOT
}

resource "vault_kubernetes_auth_backend_role" "roles" {
  for_each                         = var.apps
  backend                          = "kubernetes"
  role_name                        = each.key
  bound_service_account_names      = [each.key]
  bound_service_account_namespaces = [each.value.namespace]
  token_ttl                        = 3600
  token_policies                   = [each.key]
  audience                         = null
}