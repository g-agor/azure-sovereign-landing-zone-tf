# ADR-01: Hub-and-Spoke Topology over Azure Virtual WAN

## Status
Accepted

## Context
The landing zone needs a central network topology that connects a workload spoke to shared services (firewall, gateway, management subnet) while enforcing UK-only data residency. Azure offers two broad patterns for this:

* Classic hub-and-spoke: a hub VNet with explicit peering to each spoke, built from standard `azurerm_virtual_network` / `azurerm_virtual_network_peering` resources.
* Virtual WAN (vWAN): a Microsoft-managed backbone that automates hub routing, scales across regions, and supports SD-WAN/branch connectivity out of the box.

This deployment targets a single sovereign region pair (`uksouth`/`ukwest`), a small and known number of spokes, and a requirement that every routing decision be visible and auditable in Terraform state rather than delegated to a managed control plane.

## Decision
Use classic hub-and-spoke with explicit bi-directional VNet peering (`peer-hub-to-workload` / `peer-workload-to-hub`), rather than vWAN.

## Consequences
* **Gained:** Every route and peering relationship is an explicit, version-controlled Terraform resource — straightforward to reason about, diff in PRs, and explain in an audit.
* **Gained:** No dependency on a managed backbone service, which matters when the deployment must justify full control over routing for sovereignty/compliance reasons.
* **Cost:** Peering is manual and pairwise — every new spoke needs its own peering resources on both sides. This does not scale gracefully past a handful of spokes.
* **Follow-up:** If the landing zone grows to multi-region or needs branch/VPN-at-scale connectivity, this should be revisited in favour of vWAN — that migration is a re-architecture, not a config change, so the trigger for revisiting is documented here rather than discovered later.