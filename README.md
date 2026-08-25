# Azure-sovereign-landing-zone-tf

Sovereign/High Assurance Azure Landing Zone following Microsoft Cloud Adoption Framework (CAF) automated with Terraform and GitHub Actions.

## Engineering Log & Initial Setup Learnings

### 1. Workspace Context & Path Resolution (`terraform init`)
* **Challenge:** Encountered `Initialization in an empty directory` during local execution of `terraform init`.
* **Root Cause:** The terminal execution context was pointed at a parent directory rather than the local project root containing `.tf` files.
* **Resolution & Architectural Takeaway:** Validated path context using `pwd` and confirmed workspace directory boundaries. Ensured proper initialization of `.tf` structural files (`versions.tf`, `providers.tf`, `main.tf`) before invoking provider plugins.

### 2. Multi-Tenant Sync & CLI Authentication State
* **Challenge:** The Azure CLI threw `Subscription Not Found` errors when provisioning remote state infrastructure, despite the active subscription being visible in the Azure Portal.
* **Root Cause:** Token caching and directory context drift in local CLI sessions when interacting with newly established subscriptions or multi-tenant Entra ID environments.
* **Resolution:** Cleared local token caches (`az account clear`), re-authenticated (`az login`), explicitly targeted the active subscription ID (`az account set --subscription <ID>`), and triggered explicit provider namespace registration (`az provider register --namespace Microsoft.Storage`).

### 3. Syntax Validation & Structural Scope (`versions.tf` vs. `backend.tf`)
* **Challenge:** Triggered `Error: Unsupported block type` on the `backend "azurerm"` declaration during backend configuration.
* **Root Cause:** HCL scope misplacement (nesting the `backend` block inside `required_providers` or misplaced syntax braces within `versions.tf`).
* **Resolution & Architectural Takeaway:** Standardized code layout by breaking out modular file responsibilities. Created a dedicated `backend.tf` file containing the `terraform { backend "azurerm" { ... } }` declaration, keeping `versions.tf` focused exclusively on provider constraints. Re-initialized Terraform (`terraform init`) to successfully migrate state to remote Azure Blob Storage with locking enabled.
---

---

## Step 2: Management Group Hierarchy (CAF Alignment)

This layer implements a multi-tier Azure Management Group structure aligned with the **Microsoft Cloud Adoption Framework (CAF)** Enterprise-Scale architecture. It establishes clear organizational boundaries for policy inheritance, access control (RBAC), and sovereign workload isolation.

### Architecture Overview

```text
                     ┌────────────────────────────────┐
                     │     Tenant Root Group          │
                     └───────────────┬────────────────┘
                                     │
                     ┌───────────────▼────────────────┐
                     │   UK Sovereign Root            │
                     │   (sovereign-root)             │
                     └───────────────┬────────────────┘
                                     │
       ┌─────────────────────────────┼─────────────────────────────┐
       │                             │                             │
┌──────▼───────┐              ┌──────▼───────┐              ┌──────▼───────┐
│   Platform   │              │ LandingZones │              │ Decomm / Sand│
└──────┬───────┘              └──────┬───────┘              └──────────────┘
       │                             │
 ┌─────┴─────┬──────────┐      ┌─────┴─────┐
 │           │          │      │           │
┌▼─────────┐┌▼────────┐┌▼─────┐│ Production│
│Connectiv.││Identity ││Mgmt  │└───────────┘
└──────────┘└─────────┘└──────┘


```
---

### Hierarchy Breakdown

* **Top-Level Root (`sovereign-root`)**
  Top-level entry point. Global security guardrails inherit from here down to all child environments.

* **Platform (`sovereign-platform`)**
  Parent container for centralized IT infrastructure and shared governance services.
  * **Connectivity (`sovereign-connectivity`):** Virtual WAN / Hub-and-Spoke networks, ExpressRoute, and central firewalls.
  * **Identity (`sovereign-identity`):** Active Directory Domain Services, Key Vaults, and privilege management.
  * **Management (`sovereign-management`):** Centralized Log Analytics workspaces, Microsoft Sentinel, and backup vaults.

* **Landing Zones (`sovereign-landing-zones`)**
  Parent container designated for business application workloads.
  * **Production Workloads (`sovereign-production`):** Enforces high-assurance sovereign compliance rules for live business applications.

* **Decommissioned (`sovereign-decommissioned`)**
  Quarantined zone for legacy or retired subscriptions awaiting cleanup.

---

## Step 3: Governance & Policy Guardrails (Sovereign Controls)

This step establishes automated compliance guardrails across the management group hierarchy. By applying policy assignments directly at the **UK Sovereign Root** level, every child subscription and workload automatically inherits these sovereign security standards.

### Core Policies Enforced

* **Allowed Locations (Region Locking):** Restricts all resource deployments strictly to approved UK regions (`UK South` and `UK West`) to guarantee sovereign data residency.
* **Audit Compliance:** Evaluates all existing and future infrastructure against Microsoft sovereign landing zone guardrails.

---

### Implementation Details & Challenge Faced

* **`policies.tf`** — Uses the `azurerm_policy_definition` data source to fetch the built-in Azure "Allowed locations" policy and binds it to the root management group via `azurerm_management_group_policy_assignment`.
* **`variables.tf`** — Parameterizes allowed locations to default to `["uksouth", "ukwest"]`.
* **Inheritance Scope:** Applied at the root level so Platform, Landing Zones, and sub-groups inherit constraints without requiring duplicate policy setups.

#### Challenge Faced: Hardcoded Policy Definition ID Error
During deployment, hardcoding the raw Azure policy definition ID string triggered a `400 Bad Request (PolicyDefinitionNotFound)` error because the path could not be resolved by the provider API.

* **Solution:** Replaced the hardcoded string path with a dynamic Terraform data source (`data "azurerm_policy_definition" "allowed_locations"`). This dynamically looks up the built-in policy by its display name and retrieves the fully qualified Azure Resource ID, resolving the deployment error.

