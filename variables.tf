variable "ssh_public_keys" {
  description = "SSH public keys for jump host access"
  type        = map(string)
}

variable "jump_hosts" {
  description = "Jump host definitions"
  type = map(object({
    location    = string
    server_type = string
  }))
  default = {
    jump-eu-central = {
      location    = "nbg1"
      server_type = "cx22"
    }
    jump-eu-north = {
      location    = "hel1"
      server_type = "cx22"
    }
  }
}
