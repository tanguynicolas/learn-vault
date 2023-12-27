variable "vault_addr" {
  type        = string
  description = "Vault URL"
  default     = "http://127.0.0.1:8200"
}

variable "kvv2_path" {
  description = "KVv2 secret engine path"
  type        = string
  default     = "secrets"
}

variable "apps" {
  type = map(
    object({
      secrets   = list(string)
      namespace = string
      }
  ))
  description = "Apps to create kubernetes bindings to secrets"
  default     = {}
}