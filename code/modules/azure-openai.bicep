// params

@description('Azure OpenAI name')
param name string

@description('Resource Location')
param location string

@description('Tags')
param tags object

@description('Key Vault name')
param kvname string

// resource

resource open_ai 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: name
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: toLower(name)
  }
}

resource open_ai_ada 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: '${name}ada'
  sku: {
    capacity: 50
    name: 'Standard'
  }
  parent: open_ai
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    raiPolicyName: 'Microsoft.Default'
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
}

resource open_ai_gpt 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: '${name}gpt4o'
  sku: {
    capacity: 8
    name: 'Standard'
  }
  parent: open_ai
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'
    }
    raiPolicyName: 'Microsoft.Default'
    versionUpgradeOption: 'OnceCurrentVersionExpired'
  }
  dependsOn: [
    open_ai_ada
  ]
}

// secrets

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvname
}

resource azureOpenAIApiKey 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'azureOpenAIApiKey'
  properties: {
    value: open_ai.listKeys().key1
  }
}

resource azureOpenAIEndpoint 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'azureOpenAIEndpoint'
  properties: {
    value: open_ai.properties.endpoint
  }
  dependsOn: [
    azureOpenAIApiKey
  ]
}

resource azureOpenAIDeploymentName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  parent: keyVault
  name: 'azureOpenAIDeploymentName'
  properties: {
    value: open_ai_gpt.name
  }
  dependsOn: [
    azureOpenAIEndpoint
  ]
}

// outputs
output aoi_id string = open_ai.id
output aoi_endpoint string = open_ai.properties.endpoint
output aoiName string = open_ai.name
