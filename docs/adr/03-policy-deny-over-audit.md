# ADR-0003: Policy-as-Code Enforcement via Deny Effect (not Audit)

## Status
Accepted

## Context
Azure Policy supports (among others) two effects relevant here:

* **Audit:** Flags non-compliant resources after deployment, but doesn't block them.
* **Deny:** Blocks the deployment outright if it violates the policy.

Two guardrails are enforced at the root management group: an allowed-locations restriction (`uksouth`/`ukwest` only) and a custom policy requiring `Environment`, `CostCenter`, and `ManagedBy` tags on every resource. The premise of a "sovereign" landing zone is that data residency is a hard regulatory boundary, not a monitored one — a resource deployed outside the UK for even a few hours before an audit catches it is already a compliance failure, not a near-miss.

## Decision
Both policies use effect `deny`, assigned at `sovereign-root` so they inherit to every child management group and future subscription.

## Consequences
* **Gained:** It is structurally impossible to deploy a resource outside `uksouth`/`ukwest`, or without the three mandatory tags, anywhere under the sovereign root — not "monitored," genuinely blocked.
* **Cost:** Deny has no built-in exemption path. A legitimate need (e.g. a DR region outside the allowed list, or a break-glass resource deployed under time pressure without full tagging) is blocked the same as a genuine violation. There is currently no `azurerm_policy_exemption` mechanism in this repo to handle that case.
* **Follow-up:** Before this pattern is used for anything beyond a portfolio/demo deployment, a documented exemption process (scoped, time-boxed, logged) should be added — otherwise the first real operational exception becomes an unplanned `terraform destroy` of the policy itself, which defeats the point.