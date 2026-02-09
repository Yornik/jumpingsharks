# jumpingsharks

OpenTofu configuration for Hetzner Cloud jump hosts that serve as entry points into the **sharkshere** home lab network. Provisions servers, firewall rules, SSH keys, DNS records, and outputs an Ansible inventory for downstream configuration.

## Infrastructure

| Host | Location | Type | OS | DNS |
|------|----------|------|----|-----|
| **jump-eu-central** | Nuremberg (nbg1) | CX22 | Debian 12 | `jump.fedishark.eu` |
| **jump-eu-north** | Helsinki (hel1) | CX22 | Debian 12 | `jump.fedishark.eu` |

Both hosts share a single DNS name (`jump.fedishark.eu`) via round-robin A/AAAA records.

## What It Creates

- **SSH keys** — uploaded from `terraform.tfvars` for remote access
- **Firewall** — allows SSH (22), HTTP (80), HTTPS (443), and Tailscale UDP (41641)
- **Servers** — Debian 12 with cloud-init (package updates + python3 for Ansible)
- **DNS** — forward A/AAAA records and reverse DNS for `jump.fedishark.eu`

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.6.0
- [SOPS](https://github.com/getsops/sops) with the age key to decrypt `secrets.enc.json`

The Hetzner Cloud API token is stored in the encrypted secrets file and read via the SOPS provider.

## Usage

```sh
tofu init
tofu plan
tofu apply
```

## Configuration

| File | Purpose |
|------|---------|
| `variables.tf` | Defines `ssh_public_keys`, `jump_hosts`, and `dns_zone_name` |
| `terraform.tfvars` | SSH public keys for server access |
| `secrets.enc.json` | SOPS-encrypted Hetzner API token |
| `versions.tf` | Provider versions (hcloud ~> 1.49, sops ~> 1.1) |

Add or modify jump hosts by editing the `jump_hosts` variable — each entry needs a `location` and `server_type`.

## Outputs

- **`jump_hosts`** — IP addresses, location, status, and rDNS per server
- **`ansible_inventory`** — ready-to-use INI inventory for Ansible provisioning

## CI

Every pull request runs four checks:

1. **Format** — `tofu fmt -check`
2. **Validate** — `tofu validate`
3. **TFLint** — linting for best practices
4. **tfsec** — security scanning
