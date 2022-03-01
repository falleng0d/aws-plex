variable "region" {
  description = "AWS region"
  default     = "sa-east-1"
}

variable "machine_type" {
  description = "Desired machine type (i.e. t3a.small)"
  default     = "t3a.small"
}

variable "public_key_path" {
  description = "Public key path"
  default     = "./.ssh/id_rsa.pub"
}

variable "private_key_path" {
  description = "Private key path"
  default     = "./.ssh/id_rsa"
}
