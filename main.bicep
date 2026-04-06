// main.bicep
targetScope = 'resourceGroup'

param location string = 'uksouth'
param baseName string = 'RogersLab'

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
output managedIdentityPrincipalId string = identity.outputs.principalId
output keyVaultUri string = kv.outputs.vaultUri
// 3. Deploy the VM and link the Identity
module compute './modules/vm.bicep' = {
  name: 'deploy-vm'
  params: {
    location: location
    vmName: 'vm-rogers-lab'
    adminPassword: 'Password1234!' // In production, use a Secret, but fine for lab
    managedIdentityId: identity.outputs.resourceId // This links the modules
  }
}
