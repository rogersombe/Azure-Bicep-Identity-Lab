// modules/keyvault.bicep
param location string = resourceGroup().location
param vaultName string
param managedIdentityPrincipalId string

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true 
  }
}

// Hardcoded ID for 'Key Vault Secrets User'
var roleId = '4633458b-17de-408a-b874-0445c86b69e6'

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vault.id, managedIdentityPrincipalId, roleId)
  scope: vault
  properties: {
    principalId: managedIdentityPrincipalId
    // Using the absolute path to prevent Bicep from stripping hyphens
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleId}'
    principalType: 'ServicePrincipal'
  }
}

// This is the module's "Sign-off"
output vaultUri string = vault.properties.vaultUri
