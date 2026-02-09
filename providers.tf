data "sops_file" "hetzner" {
  source_file = "secrets.enc.json"
}

provider "hcloud" {
  token = data.sops_file.hetzner.data["hcloud_token"]
}
