# jumpingsharks

This repository creates the public edge of the sharkshere platform with OpenTofu. The edge is two small Hetzner Cloud servers, one firewall, their DNS records and their reverse DNS.

This document uses a style based on ASD-STE100 Simplified Technical English. Sentences are short. Each sentence gives one instruction or one fact.

## What this repository does

- It creates two servers: `jump-eu-central` in Nuremberg and `jump-eu-north` in Helsinki.
- It creates one firewall with five inbound rules: `tcp/22`, `tcp/80`, `tcp/443`, `tcp/2222` and `udp/41641`.
- It creates the A and AAAA records for `jump.fedishark.eu` and the PTR records for each server.
- It writes an inventory output that `sharkshere-ansible` reads.

This repository is one of three:

| Repository | Layer | Function |
|---|---|---|
| `jumpingsharks` (this repository) | infrastructure | Creates the two Hetzner edge hosts and their DNS with OpenTofu. |
| [`sharkshere-ansible`](https://github.com/Yornik/sharkshere-ansible) | hosts | Hardens the edge hosts. Installs HAProxy, Tailscale and fail2ban. |
| [`sharkshere-gitops`](https://github.com/Yornik/sharkshere-gitops) | workloads | Reconciles the applications in the cluster with ArgoCD. |

## Documents

| Document | Content |
|---|---|
| [`docs/tech/README.md`](docs/tech/README.md) | Full technical overview: resource list, host table, design notes, state management, constraints. |

## Repository layout

| File | Content |
|---|---|
| `main.tf` | Servers, firewall, SSH keys, DNS records, reverse DNS. |
| `variables.tf` | `ssh_public_keys`, `jump_hosts`, `dns_zone_name`. |
| `terraform.tfvars` | Public SSH keys. Committed. No private key is in this repository. |
| `secrets.enc.json` | The Hetzner API token, encrypted with SOPS. |
| `outputs.tf` | `jump_hosts` and `ansible_inventory`. |
| `providers.tf`, `versions.tf` | Provider configuration and version pins. |
| `renovate.json5` | Renovate rules for provider and tool versions. |

## Before you start

Make sure that you have:

- OpenTofu 1.6 or later.
- SOPS and the age key that decrypts `secrets.enc.json`.
- Access to the Hetzner Cloud project.
- The file `terraform.tfstate` from the operator workstation. See [State](#state).

## How to apply a change

1. Edit the `.tf` files.
2. Run `tofu fmt`.
3. Run `tofu init` if you changed a provider.
4. Run `tofu plan`. Read each line of the plan.
5. Open a pull request. CI runs four checks. See [CI checks](#ci-checks).
6. Merge the pull request.
7. Run `tofu apply` from `main`.
8. Run `tofu plan` again. Make sure that it reports no changes.

CAUTION: Do not change a server, a firewall rule or a DNS record in the Hetzner console. The next `tofu plan` shows the difference. Put the change in git.

WARNING: `tofu apply` can replace a server. A replaced server has a new IP address and an empty disk. Read the plan for the word `replace` before you confirm.

## How to open a new inbound port

1. Add one `rule` block to `hcloud_firewall.jump` in `main.tf`.
2. Apply the change with the procedure above.
3. Add the HAProxy frontend in `sharkshere-ansible`.

Hetzner attaches the firewall when it creates the server. New rules take effect at once.

## How to add an SSH key

1. Add the public key to `ssh_public_keys` in `terraform.tfvars`.
2. Apply the change with the procedure above.

NOTE: Hetzner injects SSH keys only at server creation. For an existing server, add the key with `sharkshere-ansible`.

## State

The state file is local. It is not in git. It is on the operator workstation. A backup of the state is next to the SOPS secrets.

CAUTION: If you lose the state file, OpenTofu does not know the servers exist. Do not run `tofu apply` without the state file. Import the resources first.

## CI checks

CI runs on each pull request. All four checks must pass before a merge.

| Check | What it does |
|---|---|
| `tofu fmt -check` | Checks the formatting of the `.tf` files. |
| `tofu validate` | Checks the syntax and the references. |
| `tflint` | Finds errors and deprecated usage. |
| `tfsec` | Finds insecure settings. |

## Known limits

The edge has two hosts in two regions. The cluster behind it is in a home. The home has one power feed, one internet uplink and one NAS. These are accepted limits. See [`docs/tech/README.md`](docs/tech/README.md#homelab-constraints) for the reasons.
