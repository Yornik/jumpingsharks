resource "hcloud_ssh_key" "default" {
  name       = "jumpingsharks"
  public_key = var.ssh_public_key
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

  ssh_keys = [hcloud_ssh_key.default.id]

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
