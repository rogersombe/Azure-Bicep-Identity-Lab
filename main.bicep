// main.bicep
targetScope = 'resourceGroup'

param location string = 'uksouth'
param baseName string = 'RogersLab'
@description('SSH public key for the lab VM')
param sshPublicKey string
// 1. Deploy the Identity Module
module identity './modules/identity.bicep' = {
  name: 'deploy-identity'
  params: {
    location: location
    identityName: 'Id-${baseName}-Identity'
  }
}

// 2. Deploy the Key Vault Module
module kv './modules/keyvault.bicep' = {
  name: 'deploy-keyvault-final' 
  params: {
    location: location
    vaultName: 'kv-rl-${uniqueString(resourceGroup().id)}' 
    managedIdentityPrincipalId: identity.outputs.principalId 
  }
}

// Final Outputs (The "Receipts")

// 3. Deploy the VM and link the Identity
module compute './modules/vm.bicep' = {
  name: 'deploy-vm'
  params: {
    location: location
    vmName: 'vm-rogers-lab'
   adminPublicKey: sshPublicKey
    managedIdentityId: identity.outputs.resourceId // This links the modules
  }
}
output managedIdentityPrincipalId string = identity.outputs.principalId
output keyVaultUri string = kv.outputs.vaultUri
