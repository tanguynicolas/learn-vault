provider "vault" {
  # Take auth from ~/.vault-token by default
  address = var.vault_addr
}