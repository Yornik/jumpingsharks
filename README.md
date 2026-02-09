# jumpingsharks

OpenTofu configuration for Hetzner jump hosts. It provisions SSH keys, a firewall, servers, and reverse DNS records, then outputs connection details and an Ansible inventory.

## What It Creates

- Hetzner Cloud SSH keys from `ssh_public_keys`.
- Firewall allowing SSH (22), HTTP (80), HTTPS (443), and Tailscale UDP 41641.
- One or more Debian 12 servers from `jump_hosts`.
- rDNS records pointing `jump.fedishark.eu` for each host.
- DNS A/AAAA records for `jump.fedishark.eu` that include all host IPs.

## Prereqs

- OpenTofu >= 1.6.0.
- SOPS with the key material needed to decrypt `secrets.enc.json`.
- Hetzner Cloud API token stored in the encrypted secrets file.

## Usage

```sh
tofu init
tofu plan
tofu apply
```

## Configuration

- `variables.tf` defines `ssh_public_keys`, `jump_hosts`, and `dns_zone_name`.
- `terraform.tfvars` provides example SSH keys.
- `secrets.enc.json` is decrypted by the SOPS provider for the Hetzner token.

## Outputs

- `jump_hosts`: IPs, location, status, and rDNS per host.
- `ansible_inventory`: INI-formatted inventory for quick use with Ansible.
