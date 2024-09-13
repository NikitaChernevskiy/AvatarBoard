// params

@description('AI Search name')
param name string

@description('Resource Location')
param location string

@description('Tags')
param tags object

@description('Key Vault name')
param kvname string

// resource

resource aiSearch 'Microsoft.Search/searchServices@2024-03-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// secrets

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvname
}

resource azurecogsearchapikey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'azurecogsearchapikey'
  properties: {
    value: aiSearch.listAdminKeys().primaryKey
  }
}

resource azurecogsearchendpoint 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'azurecogsearchendpoint'
  properties: {
    value: 'https://${aiSearch.name}.search.windows.net'
  }
  dependsOn: [
    azurecogsearchapikey
  ]
}

// outputs
output name string = aiSearch.name
output id string = aiSearch.id
