output "jump_hosts" {
  description = "Jump host connection details"
  value = {
    for name, server in hcloud_server.jump : name => {
      ipv4     = server.ipv4_address
      ipv6     = server.ipv6_address
      location = server.location
      status   = server.status
      rdns     = "${name}.fedishark.eu"
    }
  }
}

output "ansible_inventory" {
  description = "Ansible inventory in INI format"
  value = join("\n", concat(
    ["[jump_hosts]"],
    [for name, server in hcloud_server.jump :
      "${name} ansible_host=${server.ipv4_address} ansible_user=ansible location=${server.location}"
    ],
    [""]
  ))
}
