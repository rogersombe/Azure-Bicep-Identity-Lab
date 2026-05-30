// modules/identity.bicep
param location string = resourceGroup().location
param identityName string

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

output principalId string = uami.properties.principalId
output identityId string = uami.id
output resourceId string = uami.id //
