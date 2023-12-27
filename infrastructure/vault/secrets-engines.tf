resource "vault_mount" "default" {
  path        = var.kvv2_path
  type        = "kv-v2"
  description = "Internal secrets"
}