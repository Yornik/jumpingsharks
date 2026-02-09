variable "ssh_public_key" {
  description = "SSH public key for jump host access"
  type        = string
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
