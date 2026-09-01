# ADR-0005: Add Checkov Static Analysis (Soft-Fail) and Resolve Its First Finding

## Status
Accepted, with known gaps (see below)

## Context
Prior to this change, the pipeline had no automated security/compliance scanning of the Terraform itself — `terraform-ci.yml` only ran `fmt`, `init`, `validate`, and `plan`/`apply`. For a landing zone claiming "high-assurance" governance, that meant misconfigurations could be merged with nothing catching them beyond the reviewer's own eyes.

Checkov (`bridgecrewio/checkov-action`) was added as a dedicated CI job against the Terraform on every push/PR. Running it against the existing repo immediately surfaced a real finding: the workload app subnet had no Network Security Group attached at all — traffic filtering relied entirely on the hub firewall, a single point of enforcement with no defence-in-depth behind it.

Two decisions followed from this:

1. How should Checkov findings behave in CI — block the pipeline (hard-fail) or just report (soft-fail)?
2. How to respond to the subnet-NSG finding specifically.

## Decision
* Run Checkov with `soft_fail: true` — findings are logged but don't block merges, for now.
* Resolve the subnet-NSG finding by creating `nsg-appservices` and associating it with the app subnet.

## Consequences
* **Gained:** Baseline visibility that didn't exist before, and one real finding acted on immediately — the app subnet now has an independent network-layer enforcement point rather than relying solely on the hub.
* **Cost (soft-fail):** Soft-fail has no enforcement power yet: a PR with active Checkov findings currently merges exactly as freely as a clean one. This is deliberate rather than an oversight — the existing repo had never been scanned, so hard-failing immediately risked either blocking all future work on a wall of pre-existing findings, or a rushed baseline-suppression pass just to go green. Soft-fail first was chosen to see the real finding set before deciding what's worth gating on.
* **Cost (NSG fix):** The NSG fix is a scaffold, not a control: `nsg-appservices` currently has no rules of its own, so it runs on Azure's default NSG behaviour (allow-VNet-inbound, deny-internet-inbound, allow-all-outbound). It satisfies "does this subnet have an NSG associated" without yet encoding what the app subnet should actually be allowed to talk to.

## Follow-up
Triage the remaining Checkov findings, fix or explicitly suppress each with a documented reason, then flip `soft_fail` to `false`. Separately, write explicit `azurerm_network_security_rule` resources for `nsg-appservices` — e.g. inbound only from the hub's firewall/gateway subnet, deny-by-default otherwise — so the NSG is doing real filtering rather than just existing.