output "jump_hosts" {
  description = "Jump host connection details"
  value = {
    for name, server in hcloud_server.jump : name => {
      ipv4     = server.ipv4_address
      ipv6     = server.ipv6_address
      location = server.location
      status   = server.status
    }
  }
}
