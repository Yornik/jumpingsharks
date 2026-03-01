# jumpingsharks

OpenTofu infrastructure layer for the sharkshere platform.

This repo defines the public edge foundation and hands off to the other two repos:

1. `jumpingsharks` (this repo): provision cloud edge hosts, network controls, DNS/rDNS
2. `sharkshere-ansible`: configure/harden those hosts
3. `sharkshere-gitops`: run in-cluster workloads behind that edge

## Scope

- Hetzner Cloud servers
- Hetzner firewall rules
- SSH key injection
- DNS A/AAAA records
- Reverse DNS (PTR)
- Outputs consumed by Ansible

## Edge Infrastructure

| Host | Location | Type | OS | Public DNS |
|------|----------|------|----|------------|
| `jump-eu-central` | Nuremberg (`nbg1`) | `CX23` | Debian 13 | `jump.fedishark.eu` |
| `jump-eu-north` | Helsinki (`hel1`) | `CX23` | Debian 13 | `jump.fedishark.eu` |

Both hosts are published under one name (`jump.fedishark.eu`) via round-robin A/AAAA.

## Design Choices

- Two regions for basic edge resilience and maintenance flexibility.
- Infrastructure declared once in OpenTofu and versioned for review.
- DNS and PTR controlled as code to avoid config drift.
- Output contracts (`ansible_inventory`) keep infra and config repos coupled in a clean way.

## Homelab Constraints

Even with dual edge hosts, the platform still has acknowledged homelab SPOFs:

- Single home power feed
- Single home internet uplink
- Shared NAS storage dependency for part of the workload set

These are conscious tradeoffs. Fully eliminating them is feasible but currently too expensive and operationally heavy for the intended homelab scope.

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.6.0
- [SOPS](https://github.com/getsops/sops) + age key for `secrets.enc.json`

## Usage

```sh
tofu init
tofu plan
tofu apply
```

## Important Files

| File | Purpose |
|------|---------|
| `variables.tf` | `ssh_public_keys`, `jump_hosts`, `dns_zone_name` |
| `terraform.tfvars` | public SSH keys |
| `secrets.enc.json` | encrypted Hetzner API token |
| `versions.tf` | provider/version pinning |

## Outputs

- `jump_hosts`: host metadata including IPs and PTR
- `ansible_inventory`: generated inventory for `sharkshere-ansible`

## CI

PR checks:

1. `tofu fmt -check`
2. `tofu validate`
3. `tflint`
4. `tfsec`
