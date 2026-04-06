// modules/vm.bicep
param location string
param vmName string
param adminUsername string = 'azureuser'
@secure()
param adminPassword string
param managedIdentityId string // This is the 'Key' we created earlier

// 1. Virtual Network (The 'House' for the VM)
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: '${vmName}-vnet'
  location: location
  properties: {
    addressSpace: { addressPrefixes: ['10.0.0.0/16'] }
    subnets: [{
        name: 'default'
        properties: { addressPrefix: '10.0.1.0/24' }
    }]
  }
}

// 2. Network Interface (The 'Door')
resource nic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [{
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: { id: vnet.properties.subnets[0].id }
        }
    }]
  }
}

// 3. The Virtual Machine
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {} // We 'attach' the ID card to the VM here
    }
  }
  properties: {
    hardwareProfile: { vmSize: 'Standard_B1s' } // Low cost for lab
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: { createOption: 'FromImage' }
    }
    networkProfile: {
      networkInterfaces: [{ id: nic.id }]
    }
  }
}
