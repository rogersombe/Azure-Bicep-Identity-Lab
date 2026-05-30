# Azure Bicep Identity & Security Lab: Automated Zero-Trust Compute Stack

## 📝 Executive Summary
This project demonstrates an end-to-end, modular infrastructure deployment using **Azure Bicep**. The architecture implements **Secretless Authentication** by programmatically provisioning a User-Assigned Managed Identity, an Azure Key Vault, and a Virtual Machine, establishing secure RBAC bindings between them to ensure an "Identity-First" security posture.

---

## 🏗️ 1. Architectural Components

| Component | Bicep Module | Functional Definition |
| :--- | :--- | :--- |
| **Managed Identity** | `identity.bicep` | Provides a standalone security principal for workload authentication. |
| **Key Vault** | `keyvault.bicep` | A hardened repository for centralized management of secrets and keys. |
| **Virtual Machine** | `vm.bicep` | An Ubuntu 22.04 LTS compute instance with the Managed Identity injected at the hardware layer. |
| **Orchestrator** | `main.bicep` | The root template managing resource dependencies and parameter inheritance. |

### 🛰️ Resource Dependency Map
![Architecture Diagram](./architecture-diagram.jpg)

---

## 🛠️ 2. Engineering Highlights & Problem Solving

### Secretless VM Access
Eliminated static credentials entirely by disabling password authentication (`disablePasswordAuthentication: true`) and provisioning the VM with **SSH public-key access only**. No password exists anywhere in the codebase or deployment parameters — the deploy-time `sshPublicKey` parameter carries a *public* key, which is safe by design. This makes the "Identity-First / secretless" posture true in code, not merely in principle.

### Resolving a Tenant-Specific Role Definition Mismatch
During deployment, a `RoleDefinitionDoesNotExist` error was identified due to a tenant-specific GUID mismatch. The following remediation was applied:

* **API-Direct Validation:** Utilized Azure CLI to query the **Azure Resource Manager (ARM)** provider for the exact Role Definition ID required by the subscription.
* **Path Canonicalization:** Implemented absolute resource referencing (Full Resource ID paths) to prevent Bicep compilation errors and ensure idempotent role assignments.

---

## 🛡️ 3. Strategic Value (IAM & Platform Engineering)
* **Zero-Trust Security:** Removed the need for static credentials by utilizing Managed Identities for resource-to-resource communication and SSH public-key authentication for administrative access.
* **Infrastructure as Code (IaC):** Created a repeatable, version-controlled blueprint for secure environment provisioning.
* **Least Privilege Access:** Configured granular RBAC scopes, limiting the VM's access strictly to the "Key Vault Secrets User" role.

---

## 🚀 How to Deploy

### Prerequisites
* An active Azure Subscription.
* Azure CLI installed and authenticated (`az login`).
* Bicep CLI installed.
* An SSH key pair. Generate one with:
```bash
  ssh-keygen -t ed25519 -C "your-label"
```

### Steps

1. **Clone the repository:**
```bash
   git clone https://github.com/rogersombe/Azure-Bicep-Identity-Lab.git
   cd Azure-Bicep-Identity-Lab
```

2. **Create a resource group:**
```bash
   az group create --name rg-identity-lab --location uksouth
```

3. **Deploy, passing your SSH public key:**
```bash
   az deployment group create \
     --resource-group rg-identity-lab \
     --template-file main.bicep \
     --parameters sshPublicKey="$(cat ~/.ssh/id_ed25519.pub)"
```

4. **Connect to the VM (secretless — no password prompt):**
```bash
   ssh azureuser@<vm-public-ip>
```