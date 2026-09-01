# ADR-04: RBAC Bound at Management Group Scope (not Subscription)

## Status
Accepted, with a known implementation gap (see below)

## Context
As subscriptions land under `connectivity`, `management`, and `landing-zones`, roles need to apply consistently to all of them without re-granting access every time a new subscription is vended. RBAC can be bound at subscription level (granular but doesn't scale — N subscriptions means N role assignments to maintain) or at management group level (assigned once, inherited automatically by every child subscription, present and future).

## Decision
Bind `Reader` at `sovereign-root`, `Network Contributor` at `sovereign-connectivity`, and `Security Admin` at `sovereign-management` — all at management group scope, so access is correct by construction for any subscription added later without further Terraform changes.

## Consequences
* **Gained:** Correct-by-default access as the landing zone grows — no "we forgot to grant the new subscription the standard roles" drift.
* **Cost:** Broader blast radius per assignment — a mistake in a management-group-scoped role assignment affects every current and future subscription under it, not just one.

## Known Limitation
All three role assignments currently bind to `data.azurerm_client_config.current.object_id` — the identity of whoever runs `terraform apply` — rather than to an Entra ID group. This was acceptable for standing the environment up solo, but it does not reflect how this should work operationally: access should be granted to a group (e.g., `sovereign-network-admins`), with membership managed in Entra ID, so that a change of on-call engineer or a CI service principal rotation doesn't require a Terraform change to `rbac.tf`. Tracked as the next change to this file, not treated as acceptable long-term state.