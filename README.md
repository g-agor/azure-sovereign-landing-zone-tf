# azure-ent-landing-zone-tf

Enterprise-scale Azure Landing Zone automated with Terraform and GitHub Actions.

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
