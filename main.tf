resource "hcloud_ssh_key" "keys" {
  for_each = var.ssh_public_keys

  name       = each.key
  public_key = each.value
}

resource "hcloud_firewall" "jump" {
  name = "jump-host-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Tailscale WireGuard
  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "41641"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "jump" {
  for_each = var.jump_hosts

  name        = each.key
  image       = "debian-12"
  server_type = each.value.server_type
  location    = each.value.location
  user_data   = <<-CLOUD_INIT
    #cloud-config
    package_update: true
    packages:
      - python3
  CLOUD_INIT

  ssh_keys     = [for key in hcloud_ssh_key.keys : key.id]
  firewall_ids = [hcloud_firewall.jump.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = {
    role    = "jump-host"
    managed = "opentofu"
  }
}

resource "hcloud_rdns" "jump_ipv4" {
  for_each = var.jump_hosts

  server_id  = hcloud_server.jump[each.key].id
  ip_address = hcloud_server.jump[each.key].ipv4_address
  dns_ptr    = "jump.fedishark.eu"
}

resource "hcloud_rdns" "jump_ipv6" {
  for_each = var.jump_hosts

  server_id  = hcloud_server.jump[each.key].id
  ip_address = hcloud_server.jump[each.key].ipv6_address
  dns_ptr    = "jump.fedishark.eu"
}

resource "hcloud_zone_rrset" "jump_a" {
  zone = var.dns_zone_name
  name = "jump"
  type = "A"
  ttl  = 300

  records = [
    for server in hcloud_server.jump : {
      value = server.ipv4_address
    }
  ]
}

resource "hcloud_zone_rrset" "jump_aaaa" {
  zone = var.dns_zone_name
  name = "jump"
  type = "AAAA"
  ttl  = 300

  records = [
    for server in hcloud_server.jump : {
      value = server.ipv6_address
    }
  ]
}
