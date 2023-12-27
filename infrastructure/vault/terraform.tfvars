vault_addr = "http://127.0.0.1:8200"
kvv2_path  = "secrets"

apps = {
  # One policy for all secrets
  # So read capability is granted to all secrets in this dict
  my_database = {                # SA and policy name
    secrets   = ["my_database"]  # Secrets name
    namespace = "demo"
  }
}