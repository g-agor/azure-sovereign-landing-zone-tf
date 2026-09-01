# ADR-0002: OIDC Workload Identity Federation over Service Principal Secrets

## Status
Accepted

## Context
The GitHub Actions pipeline needs to authenticate to Azure to run `terraform plan` / `terraform apply`. The conventional approach stores a service principal's client secret in GitHub Actions secrets. For a landing zone branded "sovereign/high-assurance," a long-lived credential sitting in a third-party CI system is itself a compliance and blast-radius risk: if leaked, it grants standing access until manually rotated or revoked.

Azure Entra ID supports federated credentials that trust an external OIDC token issuer (here, `token.actions.githubusercontent.com`), letting GitHub Actions authenticate with a short-lived token scoped to a specific repo/branch instead of a static secret.

## Decision
Configure an Entra ID federated credential trusting GitHub's OIDC issuer, and authenticate in the pipeline via `azure/login@v2` using `client-id` / `tenant-id` / `subscription-id` only — no `client-secret` is stored anywhere.

## Consequences
* **Gained:** No long-lived credential exists in GitHub secrets to leak, rotate, or expire silently. Each run's token is short-lived and scoped to the federated subject claim (this repo, this branch).
* **Gained:** Removes an entire class of "secret sprawl" audit findings.
* **Cost:** The federated credential's subject claim is tied to this specific repo path and branch — forking, renaming, or moving the repo breaks auth until the federated credential is reconfigured to match.
* **Known gap:** The service principal is currently granted `Owner` at the subscription level to run Terraform. That's broader than least privilege and is a real follow-up — narrowing this to a custom role scoped to the specific resource types this pipeline manages is tracked as future work, not treated as solved by OIDC alone. OIDC fixes *how* the pipeline authenticates, not *what* it's allowed to do once authenticated.